**Krs Contract**  

This script allows players to sell vehicles to each other in a realistic and secure way:  
- **Detects nearby players** and lets you select them through an interface.  
- Verifies vehicle ownership and handles the ownership transfer in the database.  
- **Financial management**: transfers money between buyer and seller via inventory.  
- Includes **custom animations and notifications** to enhance the user experience.  
- Features a **Discord logging system** to track every transaction.  

Perfect for RP servers looking for a smooth and immersive vehicle sales system! 🚗

*Framework:*
- ESX

*Dependencies:*
- ox_lib
- ox_inventory


* File path

* ox_inventory/data/items.lua

```lua
	['contract'] = {
		label = 'Contract',
		consume = 0,
		stack = false,
		close = true,
		weight = 1,
		client = {
			export = 'krs_contract.contract'
		}
	},
```
![Screenshot 2024-11-13 111245](https://github.com/user-attachments/assets/7d72b375-e9c7-4648-9fbb-05c9525987ea)
![Screenshot 2024-11-13 111253](https://github.com/user-attachments/assets/3df551c0-cb5f-4188-addf-1e2ea4094601)
