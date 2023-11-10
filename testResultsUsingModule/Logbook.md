# Attempting to create a module (and failing miserably 😭)

Can you please help me getting Assert-PSRule to validate my custom rules and PSRule.Rules.Azure rules ‘_Azure.Template.*_’ and ‘_Azure.Deployment.*_’?

In both repositories I create a new branch for the creation of the module and testing of it.

| Repo            | Branch                           |
| :-------------- | :------------------------------- |
| IaC-validation  | [MyGuardrails-pwsh-module][1]    |
| myBicepSolution | [Use-pws-module-MyGuardrails][2] |

I created a pwsh module for the custom rules (which are in JSON format and 1 in pwsh) as you suggested.<br>
In this module I adhered to your documentation as much as possible. So, I renamed ‘_My.Guardrails.Baseline.Rule.yaml_’ to ‘_Baseline.Rule.yaml_’.<br>
Baseline `TestBaseline1` and `My.Guardrails3` is added to ‘_Baseline.Rule.yaml_’ (now containing _3_ baselines) reducing the number of files in the module.

## First test attempts

For each baseline I ran a test
Results:

1. [testResultsUsingModule\ModelTestResults-**My.Guardrails1**.txt][3]
2. [testResultsUsingModule\ModelTestResults-**TestBaseline1**.txt][4]
3. [testResultsUsingModule\ModelTestResults-**My.Guardrails2**.txt][5]
4. [testResultsUsingModule\ModelTestResults-**My.Guardrails3**.txt][6]

Before each test I adjusted the baseline name in ‘modules\MyGuardrails\rules\Config.Rule.yaml’.
Every test is run in its own pwsh terminal.
Executed command for testing:

```PowerShell
Assert-PSRule -InputPath .\storageAccount\storageAccount.parameters.json -Module MyGuardrails -Format File
```

None of the tests validated any of the rules 😢

## Second test attempt

I copied module `MyGuardrails` to my default PowerShell module directory ('_C:\Users\\\<account name>\\\<company OneDrive>\Documents\PowerShell\Modules\MyGuardrails_').

Using baseline `My.Guardrails3` I ran a new test in a new pwsh terminal.<br>
The command used for this test is the same as specified above.

Unfortunately, the result was exactly the previous test results.

> ```PowerShell
> [WARN] Could not find a matching rule. Please check that Path, Name and Tag parameters are correct.
> ```

## Third test attempt

Nothing has changed. Module `MyGuardrails` is still available in my default PowerShell module directory with baseline `My.Guardrails3` defined.

This time I specified parameter `-Options`.

### Command with configuration settings

```PowerShell
$psRuleConfigurationSettings = @{
    AZURE_BICEP_FILE_EXPANSION         = $true
    AZURE_BICEP_FILE_EXPANSION_TIMEOUT = 60
    AZURE_BICEP_PARAMS_FILE_EXPANSION  = $true
    AZURE_PARAMETER_FILE_EXPANSION     = $true
    AZURE_PARAMETER_FILE_METADATA_LINK = $true
}

$psRuleOptions = New-PSRuleOption -Configuration $psRuleConfigurationSettings

Assert-PSRule -InputPath .\storageAccount\storageAccount.parameters.json -Module MyGuardrails -Format File -Option $psRuleOptions
```

Again the same results.

> ```PowerShell
> [WARN] Could not find a matching rule. Please check that Path, Name and Tag parameters are correct.
> ```

## Fourth test attempt

For this test I copied module `PSRule.Rules.Azure` to `MyGuardrails2` and:

1. Renamed version directory to '0.1.0'
2. Removed al files from version directory except 'PSRule.Rules.Azure.psd1' which I renamed to 'MyGuardrails2.psd1'
3. Adjusted the module manifest by providing a new guid and having it reflect module name '_MyGuardrails2_'
4. Removed all rules
5. Added my custom rules (.JSONC and .ps1)
6. Removed directories '_manifest', 'en-AU', 'en-GB', 'en-US'
7. Emptied directory 'en' and placed markdown of my custom pwsh # Name of rule
8. Emptied directory 'rules' and placed my custom rule files (.jsonc & .ps1) and config & baseline yaml files
9. Copied module 'MyGuardrails2' to the PowerShell default module directory.
10. Executed command:

```PowerShell
Assert-PSRule -InputPath .\storageAccount\storageAccount.parameters.json -Module MyGuardrails2 -Format File
```

Results remain the same.

> ```PowerShell
> [WARN] Could not find a matching rule. Please check that Path, Name and Tag parameters are correct.
> ```

## Fifth attempt as I remembered pwsh module PowerShell-yaml

1. Copy version directory 0.1.0 to 0.2.0
2. Converted JSON rules to YAML using function `ConvertTo-Yaml`

    ```PowerShell
    $customRules = Get-Content -Path C:\git\Private\_PSRuleTesting\IaC-validation\modules\MyGuardrails\0.2.0\rules\definitions-Guardrails-000.Rule.jsonc -Raw | ConvertFrom-Json -Depth 100

    $customRules | ConvertTo-Yaml -OutFile C:\git\Private\_PSRuleTesting\IaC-validation\modules\MyGuardrails2\0.2.0\rules\definitions-Guardrails-000.Rule.yaml
    ```

3. Removed 'definitions-Guardrails-000.Rule.jsonc'
4. Updated module version in manifest to '0.2.0'
5. Updated the rules in yaml file by adding a rule separator and synopsis (with pre1fix '[YAML]' in the description) and adjusting the indent
6. Copied version 0.2.0 to the PowerShell default module directory and executed command
7. Deleted directory version 0.1.0
8. Running test

```PowerShell
Get-PSRule -Module MyGuardrails2 -ListAvailable

RuleName                            ModuleName  Synopsis
--------                            ----------  --------
My.Resource.MandatoryTags                       Resources not having the mandatory tags should be rejected.
Guardrails-000.Policy.231f0045f18f              [YAML]Storage accounts should have infrastructure encryption
Guardrails-000.Policy.9f15257d13f6              [YAML]Azure Stream Analytics jobs should use customer-managed keys to encrypt data
. . .

Assert-PSRule -InputPath .\storageAccount\storageAccount.parameters.json -Module MyGuardrails2 -Format File
```

Results remain the same.

> ```PowerShell
> [WARN] Could not find a matching rule. Please check that Path, Name and Tag parameters are correct.
> ```

[1]: https://github.com/Marc013/IaC-validation/tree/MyGuardrails-pwsh-module
[2]: https://github.com/Marc013/myBicepSolution/tree/Use-pws-module-MyGuardrails
[3]: https://github.com/Marc013/IaC-validation/blob/MyGuardrails-pwsh-module/testResultsUsingModule/ModelTestResults-My.Guardrails1.txt
[4]: https://github.com/Marc013/IaC-validation/blob/MyGuardrails-pwsh-module/testResultsUsingModule/ModelTestResults-TestBaseline1.txt
[5]: https://github.com/Marc013/IaC-validation/blob/MyGuardrails-pwsh-module/testResultsUsingModule/ModelTestResults-My.Guardrails2.txt
[6]: https://github.com/Marc013/IaC-validation/blob/MyGuardrails-pwsh-module/testResultsUsingModule/ModelTestResults-My.Guardrails3.txt