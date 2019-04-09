# Data Aggregation Strategies
This mule app is intended to show some aggregation strategies taking 2 Databases as example data sources with 2 simple objects (Order [id, name/description] and OrderDetails [id, order_id, detail1, detail2]). 
This example won't work unless you create your own databases with the required table structures and data, see the **Databases Notes** section

## Scope
The following strategies are intended to be used in Synchronous patterns such as HTTP REST services. Batch processes are not covered in this work. 
A classic usage is when defining an API-Led approach where you have to aggregate multiple data sources into a single system-api/domain-api or multiple system-apis into an aggregated process-api

## Strategies

1. **Simple Aggregation**: Retrieve identical objects from 2 different data sources and merge both lists without normalization 

2. **Aggregation with Normalization**: Retrieve different objects from 2 different data sources, normalize both lists and merge them 

3. **Sequential Aggregation with DB lookup**: Retrieve a list of objects from one data source, for each one (using a dw sequential lookup) retrieve a complementary object from another data source, merge inline both objects with dataweave

4. **Parallel Aggregation with DB lookup**: Retrieve a list of objects from one data source, split the objects and for each one (using a parallel processing request with VMs) retrieve a complementary object from another data source, aggregate the complementary objects in the reply section, merge both lists with dataweave

5. **Sequential Aggregation with DW**: Retrieve a list of objects from one data source, a list of all complementary objects from another data source, merge both lists with dataweave (filter)

6. **Sequential Aggregation with DW - filtered**: Retrieve a list of objects from one data source, a list of FILTERED complementary objects from another data source, based on the first data source data, merge both lists with dataweave (filter)

7. **Aggregation with DB Join**: Retrieve a list of objects using a DB's SQL JOIN to obtain the object with complementary data (merge of JOIN duplicate records out of scope)

8. **Aggregation with DB Join based on input filter Choice**: Depending on the input filter aggregate or not the data using parameterized queries for each branch (merge of JOIN duplicate records out of scope)

9. **Aggregation with Dynamic query based on input filter**: Depending on the input filter aggregate or not the data using dynamic queries (Don't use this unless you verify the input parameters first to avoid SQL injection) - (merge of JOIN duplicate records out of scope)

## Database Notes

This example was tested on MySQL Server 5.7.10, if you want to recreate the databases and tables, create 2 separate databases and use the DDL scripts provided `/db/*`

## Configuration
Default configurations defined in `/src/main/resources/api.{env}.properties`:

```
http.port=8081

db1.host=localhost
db1.port=3306
db1.user=
db1.password=
db1.database=DB1

db2.host=localhost
db2.port=3306
db2.user=
db2.password=
db2.database=DB2
```

## Run in Anypoint Studio
1. Clone the project from GitHub `git clone git@github.com:mulesoft-consulting/data-aggregation-strategies.git`

2. Run the project and test it - go to your browser and open `http://localhost:8081/console`

## Deploy through Runtime Manager
1. Deploy the app from Studio or from the Runtime Manager UI

## Benchmarking
### Resources and Tools
- MacBook Pro (Retina, 15-inch, Mid 2015)
	- 2.2 GHz Intel Core i7
	- 16 GB 
- Mule Runtime 3.8.5
- JMeter 2.13

### Test Scenarios and Results
Id | Database Complexity | Threads | Concurrency  | Results
------------ | ------------ | ------------- | -------------  | -------------
1 | Low (2 Orders, 3 OrderDetails) | 80 | ramp up: 5 secs | ![Scenario 1](/img/simple-low-load-low-concurrency.png)
2 | Low (2 Orders, 3 OrderDetails) | 80 | ramp up: 1 sec | ![Scenario 2](/img/simple-low-load-high-concurrency.png)
3 | Low (2 Orders, 3 OrderDetails) | 200 | ramp up: 5 secs | ![Scenario 3](/img/simple-high-load-low-concurrency.png) 
4 | Low (2 Orders, 3 OrderDetails) | 200 | ramp up: 1 sec | ![Scenario 4](/img/simple-high-load-high-concurrency.png) 
5 | High (1272 Orders, 642 OrderDetails) | 20 | ramp up: 5 secs | ![Scenario 5](/img/complex-low-load-low-concurrency.png) 
6 | High (1272 Orders, 642 OrderDetails) | 20 | ramp up: 1 sec | ![Scenario 6](/img/complex-low-load-high-concurrency.png) 
7 | High (1272 Orders, 642 OrderDetails) | 50 | ramp up: 5 secs | ![Scenario 7](/img/complex-high-load-low-concurrency.png) 
8 | High (1272 Orders, 642 OrderDetails) | 50 | ramp up: 1 sec | ![Scenario 8](/img/complex-high-load-high-concurrency.png) 

### Conclusions
- Aggregating the data at the source system level has the best performance, but normally this is not possible because of many reasons
- When dealing with simple objects and LOW concurrency, there's no significative difference between making a lookup with:
	- for-each 
	- 'map' + 'lookup' in dataweave
	- parallel processing with VMs
	- processing with flow-refs
- The difference starts when you increase the complexity of the objects and the concurrency, clearly, the best approach (after the JOIN at the source system level) is to obtain ALL the objects from one data source and ALL the required/filtered objects from the second data source and merge them with Dataweave
- The best option to process the lookups in parallel clearly is using splitter + request-reply with VMs + collection-aggregator

### Decision Table
Order | Strategy number | Strategy description | When to use it?
------------ | ------------ | ------------ | ------------
1 | 7,8,9 | Join at the source system level | Every time you can make the Join in the source system directly (e.g, DB JOIN)
2 | 6 | Obtain all from the first data source, obtain a filtered list from the second data source, merge with DW | When you can't do the previous one, and you are able to filter the results from the second data source, based on the data from the first data source 
3 | 5 | Obtain all from the first data source, obtain all from the second data source, merge with DW | When you can't do the previous one, and you are able to select all the records from the second data source
4 | 4 | Obtain all from the first data source, obtain one by one from the second data source using parallel processing with VMs, merge with DW | When you can't do the previous one, and you have to obtain the lookup records one by one

## Final Note
Enjoy and provide feedback / contribute :)
