param(
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\assets\moscow_apartments_2023.csv")
)

$ErrorActionPreference = "Stop"

$culture = [System.Globalization.CultureInfo]::InvariantCulture
$random = [System.Random]::new(2023)

function Next-DoubleRange([double]$min, [double]$max) {
    return $min + ($random.NextDouble() * ($max - $min))
}

function Next-IntRange([int]$minInclusive, [int]$maxExclusive) {
    return $random.Next($minInclusive, $maxExclusive)
}

function Clamp-Int([int]$value, [int]$minValue, [int]$maxValue) {
    if ($value -lt $minValue) {
        return $minValue
    }
    if ($value -gt $maxValue) {
        return $maxValue
    }
    return $value
}

function Select-Weighted([object[]]$items) {
    $totalWeight = 0.0
    foreach ($item in $items) {
        $totalWeight += [double]$item.Weight
    }

    $roll = $random.NextDouble() * $totalWeight
    $cursor = 0.0

    foreach ($item in $items) {
        $cursor += [double]$item.Weight
        if ($roll -le $cursor) {
            return $item
        }
    }

    return $items[-1]
}

$districts = @(
    @{ Name = "CAO"; BasePpm = 650000; Weight = 0.05; MetroBias = -4 },
    @{ Name = "ZAO"; BasePpm = 360000; Weight = 0.11; MetroBias = -2 },
    @{ Name = "SZAO"; BasePpm = 340000; Weight = 0.09; MetroBias = -1 },
    @{ Name = "YUZAO"; BasePpm = 315000; Weight = 0.11; MetroBias = -1 },
    @{ Name = "SAO"; BasePpm = 300000; Weight = 0.11; MetroBias = 0 },
    @{ Name = "SVAO"; BasePpm = 280000; Weight = 0.11; MetroBias = 1 },
    @{ Name = "YUAO"; BasePpm = 270000; Weight = 0.10; MetroBias = 1 },
    @{ Name = "VAO"; BasePpm = 255000; Weight = 0.10; MetroBias = 2 },
    @{ Name = "YUVAO"; BasePpm = 245000; Weight = 0.11; MetroBias = 2 },
    @{ Name = "NAO"; BasePpm = 210000; Weight = 0.11; MetroBias = 5 }
)

$roomBands = @(
    @{ Rooms = 1; AreaMin = 24; AreaMax = 44; Weight = 0.35; PpmBonus = 18000 },
    @{ Rooms = 2; AreaMin = 42; AreaMax = 72; Weight = 0.34; PpmBonus = 11000 },
    @{ Rooms = 3; AreaMin = 60; AreaMax = 106; Weight = 0.22; PpmBonus = 0 },
    @{ Rooms = 4; AreaMin = 88; AreaMax = 156; Weight = 0.09; PpmBonus = -15000 }
)

$buildingTypeBonus = @{
    0 = 0
    1 = 14000
    2 = 32000
}

$conditionBonus = @{
    0 = 0
    1 = 21000
    2 = 47000
}

$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("price,area_m2,rooms,floor,floors_total,metro_minutes,district_index,condition_code,building_type_code,built_year,parking,balcony,new_build")

for ($i = 0; $i -lt 720; $i++) {
    $district = Select-Weighted $districts
    $roomBand = Select-Weighted $roomBands

    $newBuildProbability = switch ($district.Name) {
        "CAO" { 0.44 }
        "ZAO" { 0.39 }
        "NAO" { 0.52 }
        default { 0.31 }
    }

    $newBuild = if ($random.NextDouble() -lt $newBuildProbability) { 1 } else { 0 }

    if ($newBuild -eq 1) {
        $buildingTypeRoll = $random.NextDouble()
        $buildingType = if ($buildingTypeRoll -lt 0.84) { 2 } elseif ($buildingTypeRoll -lt 0.94) { 1 } else { 0 }
    } else {
        $buildingTypeRoll = $random.NextDouble()
        $buildingType = if ($buildingTypeRoll -lt 0.45) { 0 } elseif ($buildingTypeRoll -lt 0.73) { 1 } else { 2 }
    }

    $area = [math]::Round((Next-DoubleRange $roomBand.AreaMin $roomBand.AreaMax) + (Next-DoubleRange -1.4 1.4), 1)

    if ($newBuild -eq 1) {
        $floorsTotal = switch ($buildingType) {
            2 { Next-IntRange 18 38 }
            1 { Next-IntRange 12 28 }
            default { Next-IntRange 10 24 }
        }
        $builtYear = Next-IntRange 2019 2024
    } else {
        $floorsTotal = switch ($buildingType) {
            2 { Next-IntRange 12 31 }
            1 { Next-IntRange 5 22 }
            default { Next-IntRange 5 18 }
        }
        $builtYear = switch ($buildingType) {
            2 { Next-IntRange 2004 2019 }
            1 { Next-IntRange 1958 2016 }
            default { Next-IntRange 1965 2011 }
        }
    }

    $floor = Next-IntRange 1 ($floorsTotal + 1)
    $metroMinutes = Clamp-Int ([int][math]::Round((Next-DoubleRange 4 24) + $district.MetroBias + (Next-DoubleRange -2.2 2.2))) 2 30

    if ($newBuild -eq 1) {
        $conditionRoll = $random.NextDouble()
        $conditionCode = if ($conditionRoll -lt 0.16) { 0 } elseif ($conditionRoll -lt 0.68) { 1 } else { 2 }
    } else {
        $conditionRoll = $random.NextDouble()
        $conditionCode = if ($conditionRoll -lt 0.30) { 0 } elseif ($conditionRoll -lt 0.74) { 1 } else { 2 }
    }

    $parking = if ($random.NextDouble() -lt ($(if ($newBuild -eq 1) { 0.63 } else { 0.28 }))) { 1 } else { 0 }
    $balcony = if ($random.NextDouble() -lt ($(if ($roomBand.Rooms -ge 3) { 0.72 } else { 0.61 }))) { 1 } else { 0 }

    $floorBonus = if ($floor -eq 1 -or $floor -eq $floorsTotal) { -14000 } elseif ($floor -ge 3 -and $floor -le ($floorsTotal - 2)) { 7000 } else { -2000 }
    $metroPenalty = $metroMinutes * 3000
    $ageBonus = if ($builtYear -ge 2000) { ($builtYear - 2000) * 950 } else { -9000 }
    $sizeBonus = if ($area -lt 38) { 24000 } elseif ($area -gt 110) { -22000 } elseif ($area -gt 85) { -9000 } else { 0 }
    $premiumBonus = if ($district.BasePpm -ge 500000 -and $conditionCode -eq 2) { 38000 } else { 0 }
    $newBuildBonus = if ($newBuild -eq 1) { 42000 } else { 0 }
    $parkingBonus = if ($parking -eq 1) { 12000 } else { 0 }
    $balconyBonus = if ($balcony -eq 1) { 6000 } else { 0 }
    $noise = Next-DoubleRange -17000 17000

    $pricePerSquareMeter =
        [double]$district.BasePpm +
        [double]$roomBand.PpmBonus +
        [double]$buildingTypeBonus[$buildingType] +
        [double]$conditionBonus[$conditionCode] +
        $newBuildBonus +
        $parkingBonus +
        $balconyBonus +
        $floorBonus +
        $ageBonus +
        $sizeBonus +
        $premiumBonus -
        $metroPenalty +
        $noise

    if ($pricePerSquareMeter -lt 185000) {
        $pricePerSquareMeter = 185000 + (Next-DoubleRange 0 12000)
    }

    $priceNoise = Next-DoubleRange -350000 350000
    $price = [math]::Round(($pricePerSquareMeter * $area) + $priceNoise, 0)

    if ($price -lt 4500000) {
        $price = 4500000 + [math]::Round((Next-DoubleRange 0 550000), 0)
    }

    $row = @(
        [string]::Format($culture, "{0:0}", $price),
        [string]::Format($culture, "{0:0.0}", $area),
        $roomBand.Rooms,
        $floor,
        $floorsTotal,
        $metroMinutes,
        $district.BasePpm,
        $conditionCode,
        $buildingType,
        $builtYear,
        $parking,
        $balcony,
        $newBuild
    ) -join ","

    $rows.Add($row)
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = [System.IO.Path]::GetDirectoryName($resolvedOutput)

if (-not [System.IO.Directory]::Exists($outputDirectory)) {
    [System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
}

Set-Content -Path $resolvedOutput -Value $rows -Encoding utf8
