Login-AzAccount
Get-AzSubscription

Select-AzSubscription -Subscription 2c6f3c8e-2e8f-43ac-a872-9714d5476623
 
$customrole = Get-AzRoleDefinition "Network Contributor"
$customrole.Id = $null
$customrole.Name = "Virtual Network Peering Role"
$customrole.IsCustom = 1
$customrole.Description = "Provides the ability to peer centrally managed vnet's."
$customrole.Actions.Clear()
$customrole.Actions.Add("Microsoft.Network/virtualNetworks/virtualNetworkPeerings/*")
$customrole.AssignableScopes.Clear()
$customrole.AssignableScopes.Add("/subscriptions/65502239-ebde-490b-935e-65ffc2296f87")

New-AzRoleDefinition -Role $customrole 