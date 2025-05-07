# Task 1

## Amount calculation
In order to calculate the total amount on the Expense__c object I have decided to make changes to the underlying technical requirements. 

#### Initial requeremnets for `Expense` object
| Name | Type | Other |
| ------------- | ------------- | ------------- |
| Total Amount | Number | (6,2) |
| All Approved? | Checkbox | Default - False |

#### Improved requeremnets for `Expense` object
| Name | Type | Other |
| ------------- | ------------- | ------------- |
| Approved Amount | Roll-up summary field | Ammount sum of all related Expense_Items__c that are approved  |
| Total Amount | Formula field | If **All Approved?** equal to TRUE set value to **Approved Amount** otherwise set value to 0.0 |
| All Approved? | Checkbox | Default - False |

The reason for making changes to the technical requirements are as followed:
* Less development time.
* Less testing time.
* Less deployment time.
* Reducing code debt by delegating functionality to an existing out-of-the-box solution.
* Reducing the chance of a calculation error.
* Better system performance(in comparison to a custom solution).

The down side of such changes are that users will not be able to make **direct** changes to the `Total Amount` field on the `Expense__c` object, emphasize on word **direct** as users will still be able to make indirect changes to the `Total Amount` field. An example of indirect changes would be to add a `Discount` field that will subtract it's value from the `Total Amount` field.



# Task 2