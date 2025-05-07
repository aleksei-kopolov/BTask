# Task 1
Files:
* `ExpenseItemTrigger.trigger`
* `ExpenseTrigger.trigger`
* `TriggerHandler.cls` - Virtual class that all trigger handlers inherit. Helps with segregating logic and aggregate trigger data.
* `ExpenseItemTriggerHandler.cls` - Class that hold all business logic logic related to **Expense Item** object.
* `ExpenseTriggerHandler.cls` - Class that hold all business logic logic related to **Expense** object.


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

The down side of such changes are that users will not be able to make **direct** changes to the `Total Amount` field on the Expense object, emphasize on word **direct** as users will still be able to make indirect changes to the `Total Amount` field. An example of indirect changes would be to add a `Discount` field that will subtract it's value from the `Total Amount` field.

The only major limitation for this solution is that, it might rune into errors in cases of "Data Skew". "Data Skew" are cases where 1 parent has more than 10 000 children. Theoretically this is a very extreme case and if it will happen it will require a data restructuring as Salesforce heavily recommends avoiding all cases of "Data Skew".

## Approved status synchronization
The approval status synchronization part has been done as requested with a minor change. In the task it was mentined that changes to `All Approved?` field, on the **Expense** object, have to be propagated to the `Approved?` field, on related child records(**Expense Items**) and vice versa. While propagating changes from parent to child and child to parent are responsible requirements, I believe that an additional requirement should be added. "Children should not propagate changes to other children of same parent", if this rule is not added then you can run into a case where:

1) `All Approved?` is set to TRUE.
2) On a related child, user changes `Approved?` to FALSE.
3) **Expense items** trigger fires and propogates changes to parent. Parent `All Approved?` is set to FALSE.
4) **Expense** trigger fires and propogates changes to child. All related children are set to FALSE.

As for the solution it self:
* All of the logic has been bulkified, in order to be able to process multiple records at the same time.
* SOQL queried are written in a manner to request only the necessary data and in some cases only aggregation data is returned, this is done to reduce processing time and to reduce the chance of running into governor limits.

The only major limitation this solution has, is for cases when a bulk of records are beeing processd and the number of records that have to be retrived(only records that need to be changed are retrived) is more than 50 000 records. 

In other words the solution will not work for cases where 200 parent records are being updated at the same time and each parent has a minimum of 250 child records that, are **NEEDED** to be updated. If hypothetically, it is expected that such cases will occur then a completely different solution will have to be used. That solution will require the development of asynchronous process, which will take significantly more development time(5x to 10x times), and will require data structure changes.


# Task 2
Classes:
* `TaskScheduler.cls` - Class that executes batch job.
* `OverdueTaskBatchJob.cls` - Class that processes batched Tasks.

It's a simple batchable class that queries only the necessary Tasks and updates them in bulk, there is not much stuff to do here. The only question is how often do you want this batch to run?

As for the limitations, there are only 2 of them that, come to my mind:
* Task object has a custome trigger or processes that are not designed to be able process large number of Tasks at the same time.
* Data skew.

It should be mentioned that bough of the cases are fairly extreme and the solution would be to limit the number of records being processd at the same time by the batch.