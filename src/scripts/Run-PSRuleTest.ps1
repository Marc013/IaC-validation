Set-Location -Path 'C:\Temp\myBicepSolution'
[System.IO.FileInfo[]]$resourceManagerTemplates = 'C:\Temp\myBicepSolution\storageAccount\storageAccount.parameters.json'

# $customRulePath = @('C:\Temp\IaC-validation\.ps-rule')
$customRulePath = @('C:\Temp\myBicepSolution\.ps-rule')

$psRuleConfigurationSettings = @{
    AZURE_BICEP_FILE_EXPANSION         = $true
    AZURE_BICEP_FILE_EXPANSION_TIMEOUT = 60
    AZURE_BICEP_PARAMS_FILE_EXPANSION  = $true
    AZURE_PARAMETER_FILE_EXPANSION     = $true
    AZURE_PARAMETER_FILE_METADATA_LINK = $true
}

$psRuleOptionSettings = @{
    'Binding.TargetName'            = @('ResourceName', 'name')
    'Binding.TargetType'            = @('ResourceType', 'type')
    'Execution.DuplicateResourceId' = 2
    'Execution.RuleExcluded'        = 2
    'Include.Module'                = 'PSRule.Rules.Azure'
    'Include.Path'                  = $customRulePath
    'Input.Format'                  = 'File'
    'Logging.RulePass'              = 'Information'
    'Output.As'                     = 'Detail'
    'Output.Culture'                = 'en'
    'Output.Outcome'                = 'all'
    'Requires'                      = @{ 'PSRule' = '>=2.9.0'; 'PSRule.Rules.Azure' = '>=1.30.3' }
    # 'Rule.Baseline'                 = 'TestBaseline1'
    'Rule.Exclude'                  = $ExcludeRule
}

$psRuleOptions = New-PSRuleOption -Configuration $psRuleConfigurationSettings -Option $psRuleOptionSettings

$psRuleParameters = @{
    InputPath   = $resourceManagerTemplates
    # Option      = $psRuleOptions
    # Baseline    = 'My.Guardrails1'
    ErrorAction = 'Stop'
}

# Assert-PSRule @psRuleParameters
Assert-PSRule -InputPath C:\Temp\myBicepSolution\storageAccount\storageAccount.parameters.json -Module PSRule.Rules.Azure -Format File -Baseline My.Guardrails3