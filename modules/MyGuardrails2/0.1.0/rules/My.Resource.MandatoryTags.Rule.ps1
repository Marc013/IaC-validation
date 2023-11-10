#
# My validation rules for Azure template and parameter files
#

#region Template

[hashtable]$ruleParameters = @{
    Ref   = 'My-000001'
    Level = 'Error'
    With  = 'PSRule.Rules.Azure\Azure.Resource.SupportsTags'
    Tag   = @{
        release = 'Me'
        ruleSet = 'guardrails'
    }
}

# Synopsis: Me - should reject when missing mandatory tags
Rule @ruleParameters -Name 'My.Resource.MandatoryTags' -Body {
    if ($TargetObject.'$schema') {
        $JsonObject = $TargetObject.resources
    }
    elseif ($TargetObject.FullName -match '\.json$') {
        $JsonObject = $PSRule.GetContent($TargetObject)[0].resources
    }
    else {
        $JsonObject = $TargetObject
    }

    [array]$ResourceObjects = @()
    foreach ($ResourceObject in $JsonObject) {
        if ($ResourceObject.Type -ne 'Microsoft.Resources/deployments') {
            $ResourceObjects += $ResourceObject
        }
        elseif ($ResourceObject.Type -eq 'Microsoft.Resources/deployments') {
            foreach ($Resource in $ResourceObject.properties.template.resources) {
                $ResourceObjects += $Resource
            }
        }
    }

    foreach ($Object in $ResourceObjects) {
        $hasTags = $Assert.HasField($Object, 'tags')
        if (!$hasTags.Result) {
            return $hasTags
        }

        AnyOf {
            $Assert.Match($Object, 'tags', '^\[.*\]$', $true)

            AllOf {
                $Assert.HasField($Object.tags, 'ApplicationID', $True) ? $Assert.Match($Object, 'tags.ApplicationID', '^[0-9]{8}$', $True) : $null

                $Assert.HasField($Object.tags, 'CostCode', $True) ? $Assert.Match($Object, 'tags.CostCode', '^[0-9]{10}$', $True) : $null

                $Assert.HasField($Object.tags, 'Environment', $True) ? $Assert.Match($Object, 'tags.Environment', '^(Development|Production|Staging)$|(^\[.*\]$)', $True) : $null

                $Assert.HasField($Object.tags, 'Owner', $True)
            }
        }
    }
}
