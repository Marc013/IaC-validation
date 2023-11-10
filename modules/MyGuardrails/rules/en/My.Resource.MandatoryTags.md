---
severity: Critical
pillar: Operational Excellence
category: Configuration
resource: All resources
---

# Required resource tags

## SYNOPSIS

Resources not having the mandatory tags should be rejected.

## DESCRIPTION

Tags are metadata elements that you apply to your Azure resources. They're key-value pairs that help you identify resources based on settings that are relevant to your organization. If you want to track the deployment environment for your resources, add a key named `Environment`. To identify the resources deployed to production, give them a value of `Production`. The fully-formed key-value pair is `Environment = Production`.

## RECOMMENDATION

Specify mandatory resource tags.

- ApplicationID
- CostCode
- Environment
- Owner

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Define the mandatory tags.

For example:

```json
{
    "comments": "Storage Account",
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "[variables('storageAPIVersion')]",
    "name": "[parameters('storageAccountName')]",
    "location": "[parameters('location')]",
    "dependsOn": [],
    "tags": {
        "ApplicationID": "[parameters('Tag_ApplicationID')]",
        "CostCode": "[parameters('Tag_CostCode')]",
        "Environment": "[parameters('Tag_Environment')]",
        "Owner": "[parameters('Tag_Owner')]"
    },
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Define the mandatory tags.

For example:

```bicep
resource st0000001 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: 'st0000001'
  location: location
  tags: {
    ApplicationID: '[parameters('Tag_ApplicationID')]'
    CostCode: '[parameters('Tag_CostCode')]'
    Environment: '[parameters('Tag_Environment')]'
    Owner: '[parameters('Tag_Owner')]'
  }
}
```

## LINKS

- [Use tags to organize your Azure resources and management hierarchy:][1]

[1]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources
