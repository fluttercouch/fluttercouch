//
//  QueryJson.swift
//  fluttercouch
//
//  Created by Saltech Systems on 4/8/19.
//

import Foundation
import CouchbaseLiteSwift

public class QueryJson {
    private let queryMap: QueryMap
    private var query: Query? = nil
    weak private var mCBManager: CBManager?
    
    init(json: Any, manager: CBManager) {
        self.mCBManager = manager
        self.queryMap = QueryMap(jsonObject: json)
    }
    
    static func resultSetToJson(results: ResultSet) -> NSArray {
        var resultArr: Array<Dictionary<String,Any>> = []
        for result in results.allResults() {
            var value = Dictionary<String,Any>()
            value["map"] = result.toDictionary()
            value["list"] = result.toArray()
            resultArr.append(value)
        }
        
        return NSArray(array: resultArr)
    }
    
    func toCouchbaseQuery() -> Query? {
        if (queryMap.hasSelectResult) {
            inflateSelect()
        }
        if (queryMap.hasFrom) {
            inflateFrom()
        }
        if (queryMap.hasJoins) {
            inflateJoins()
        }
        if (queryMap.hasWhere) {
            inflateWhere()
        }
        if (queryMap.hasOrderBy) {
            inflateOrderBy()
        }
        if (queryMap.hasGroupBy) {
            inflateGroupBy()
        }
        if (queryMap.hasLimit) {
            inflateLimit()
        }
        return query
    }
    
    private func inflateLimit() {
        let limitArray = queryMap.limit
        if (limitArray.count == 1) {
            let limitExpression = inflateExpressionFromArray(expressionParametersArray: limitArray)
            switch query {
            case let _from as From:
                query = _from.limit(limitExpression)
            case let _joins as Joins:
                query = _joins.limit(limitExpression)
            case let _where as Where:
                query = _where.limit(limitExpression)
            case let _orderBy as OrderBy:
                query = _orderBy.limit(limitExpression)
            case let _groupBy as GroupBy:
                query = _groupBy.limit(limitExpression)
            default:
                break
            }
        } else if (limitArray.count == 2) {
            let limitExpression = inflateExpressionFromArray(expressionParametersArray:[limitArray[0]])
            let offsetExpression = inflateExpressionFromArray(expressionParametersArray:[limitArray[1]])
            
            switch query {
            case let _from as From:
                query = _from.limit(limitExpression, offset: offsetExpression)
            case let _joins as Joins:
                query = _joins.limit(limitExpression, offset: offsetExpression)
            case let _where as Where:
                query = _where.limit(limitExpression, offset: offsetExpression)
            case let _orderBy as OrderBy:
                query = _orderBy.limit(limitExpression, offset: offsetExpression)
            case let _groupBy as GroupBy:
                query = _groupBy.limit(limitExpression, offset: offsetExpression)
            default:
                break
            }
        }
    }
    
    private func inflateGroupBy() {
        let groupByArray = queryMap.groupBy
        
        switch query {
        case let _from as From:
            query = _from.groupBy(inflateGrouping(groupByArray: groupByArray))
        case let _where as Where:
            query = _where.groupBy(inflateGrouping(groupByArray: groupByArray))
        default:
            break
        }
    }
    
    private func inflateGrouping(groupByArray: Array<Dictionary<String, Any>>) -> Array<ExpressionProtocol> {
        var groupingArray: Array<ExpressionProtocol> = []
        
        for currentGroupByExpression in groupByArray {
            groupingArray.append(inflateExpressionFromArray(expressionParametersArray: [currentGroupByExpression]))
        }
        
        return groupingArray
    }
    
    private func inflateOrderBy() {
        let orderByArray = queryMap.orderBy
        
        switch query {
        case let _from as From:
            query = _from.orderBy(inflateOrdering(orderByArray: orderByArray))
        case let _joins as Joins:
            query = _joins.orderBy(inflateOrdering(orderByArray: orderByArray))
        case let _where as Where:
            query = _where.orderBy(inflateOrdering(orderByArray: orderByArray))
        default:
            break
        }
    }
    
    private func inflateOrdering(orderByArray: Array<Array<Dictionary<String, Any>>>) -> Array<OrderingProtocol> {
        var resultOrdering: Array<OrderingProtocol> = []
        
        for currentOrderByArgument in orderByArray {
            let expression = inflateExpressionFromArray(expressionParametersArray: currentOrderByArgument)
            let ordering = Ordering.expression(expression)
            
            if let orderingSortOrder = currentOrderByArgument.last?["orderingSortOrder"] as? String  {
                if (orderingSortOrder == "ascending") {
                    resultOrdering.append(ordering.ascending());
                } else if (orderingSortOrder == "descending") {
                    resultOrdering.append(ordering.descending());
                }
            } else {
                resultOrdering.append(ordering)
            }
        }
        
        return resultOrdering
    }
    
    private func inflateJoins() {
        let joinsArray = queryMap.joins
        guard let joinArguments = joinsArray.first else {
            return
        }
        
        let joinName: String
        let joinCallback: (DataSourceProtocol) -> JoinProtocol
        if let _joinName = joinArguments["join"] as? String {
            joinCallback = Join.join(_:)
            joinName = _joinName
        } else if let _joinName = joinArguments["crossJoin"] as? String {
            joinCallback = Join.crossJoin(_:)
            joinName = _joinName
        } else if let _joinName = joinArguments["innerJoin"] as? String {
            joinCallback = Join.innerJoin(_:)
            joinName = _joinName
        } else if let _joinName = joinArguments["leftJoin"] as? String {
            joinCallback = Join.leftJoin(_:)
            joinName = _joinName
        } else if let _joinName = joinArguments["leftOuterJoin"] as? String {
            joinCallback = Join.leftOuterJoin(_:)
            joinName = _joinName
        } else {
            return
        }
        
        let dataSource: DataSourceProtocol?
        if let alias = joinArguments["as"] as? String {
            dataSource = getDatasourceFromString(name: joinName, alias: alias)
        } else {
            dataSource = getDatasourceFromString(name: joinName)
        }
        
        if let checkedDatasource = dataSource, let _from = query as? From {
            if joinsArray.count == 1 {
                query = _from.join(joinCallback(checkedDatasource))
            } else if let joinOn = joinsArray.last?["on"] {
                let onExpression = inflateExpressionFromArray(expressionParametersArray: QueryMap.getListOfMapFromGenericList(objectList: joinOn))
                query = _from.join((joinCallback(checkedDatasource) as! JoinOnProtocol).on(onExpression))
            }
        }
    }
    
    private func inflateFrom() {
        let databaseSource = queryMap.from;
        
        guard let _select = query as? Select else {
            return
        }
        
        guard let databaseName = databaseSource?["database"] as? String else {
            return
        }
        
        let dataSource: DataSourceProtocol?
        if let alias = databaseSource?["as"] as? String {
            dataSource = getDatasourceFromString(name: databaseName, alias: alias)
        } else {
            dataSource = getDatasourceFromString(name: databaseName)
        }
        
        if let dataSource = dataSource {
            query = _select.from(dataSource)
        }
    }
    
    private func inflateSelect() {
        if (queryMap.selectDistinct) {
            query = QueryBuilder.selectDistinct(inflateSelectResultArray())
        } else {
            query = QueryBuilder.select(inflateSelectResultArray())
        }
    }
    
    private func getDatasourceFromString(name: String) -> DataSourceProtocol? {
        guard let database = mCBManager?.getDatabase(name: name) else {
            return nil
        }
        
        return DataSource.database(database);
    }
    
    private func getDatasourceFromString(name: String, alias: String) -> DataSourceProtocol? {
        guard let database = mCBManager?.getDatabase(name: name) else {
            return nil
        }
        
        return DataSource.database(database).as(alias);
    }
    
    private func inflateSelectResultArray() -> Array<SelectResultProtocol> {
        let selectResultArray = queryMap.selectResult
        var result: Array<SelectResultProtocol> = []
        
        for selectResultParamArray in selectResultArray {
            result.append(inflateSelectResult(selectResultParametersArray: selectResultParamArray))
        }
        
        return result
    }
    
    private func inflateSelectResult(selectResultParametersArray: Array<Dictionary<String, Any>> ) -> SelectResultProtocol {
        let result = SelectResult.expression(inflateExpressionFromArray(expressionParametersArray: selectResultParametersArray))
        
        if let alias = selectResultParametersArray.last?["as"] as? String {
            return result.as(alias)
        }
        
        return result
    }
    
    private func inflateWhere() {
        let whereObject = queryMap.mWhere
        
        if let _from = query as? From {
            query = _from.where(inflateExpressionFromArray(expressionParametersArray: whereObject))
        } else if let _joins = query as? Joins {
            query = _joins.where(inflateExpressionFromArray(expressionParametersArray: whereObject))
        }
    }
    
    private func inflateExpressionFromArray(expressionParametersArray: Array<Dictionary<String, Any>> ) -> ExpressionProtocol {
        var returnExpression: ExpressionProtocol? = nil
        for currentExpression in expressionParametersArray {
            guard let currentKey = currentExpression.keys.first, let currentValue = currentExpression[currentKey] else {
                // If property is the key and null is the value then it is an all expression
                if currentExpression.keys.first == "property" {
                    returnExpression = Expression.all()
                }
                
                continue
            }
            
            if let existingExpression = returnExpression {
                switch (currentKey, currentValue) {
                case ("from", let alias as String):
                    if let existingExpression = returnExpression as? PropertyExpressionProtocol {
                        returnExpression = existingExpression.from(alias)
                    } else if let existingExpression = returnExpression as? MetaExpressionProtocol {
                        returnExpression = existingExpression.from(alias)
                    }
                case ("add", let value):
                    returnExpression = existingExpression
                        .add(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("and", let value):
                    returnExpression = existingExpression
                        .and(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("divide", let value):
                    returnExpression = existingExpression
                        .divide(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("equalTo", let value):
                    returnExpression = existingExpression
                        .equalTo(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("greaterThan", let value):
                    returnExpression = existingExpression
                        .greaterThan(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("greaterThanOrEqualTo", let value):
                    returnExpression = existingExpression
                        .greaterThanOrEqualTo(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("is", let value):
                    returnExpression = existingExpression
                        .is(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("isNot", let value):
                    returnExpression = existingExpression
                        .isNot(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("isNullOrMissing", _):
                    returnExpression = existingExpression.isNullOrMissing()
                case ("lessThan", let value):
                    returnExpression = existingExpression
                        .lessThan(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("lessThanOrEqualTo", let value):
                    returnExpression = existingExpression
                        .lessThanOrEqualTo(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("like", let value):
                    returnExpression = existingExpression
                        .like(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("modulo", let value):
                    returnExpression = existingExpression
                        .modulo(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("multiply", let value):
                    returnExpression = existingExpression
                        .multiply(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("notEqualTo", let value):
                    returnExpression = existingExpression
                        .notEqualTo(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("notNullOrMissing", _):
                    returnExpression = existingExpression.notNullOrMissing()
                case ("or", let value):
                    returnExpression = existingExpression
                        .or(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("regex", let value):
                    returnExpression = existingExpression
                        .regex(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                case ("subtract", let value):
                    returnExpression = existingExpression
                        .subtract(inflateExpressionFromArray(expressionParametersArray:
                            QueryMap.getListOfMapFromGenericList(objectList: value))
                        )
                default:
                    break
                }
            } else {
                switch (currentKey, currentValue) {
                case ("property", let value as String):
                    returnExpression = Expression.property(value)
                case ("property", _ as NSNull):
                    returnExpression = Expression.all()
                case ("meta", let value as String):
                    if (value == "id") {
                        returnExpression = Meta.id
                    } else if (value == "sequence") {
                        returnExpression = Meta.sequence
                    }
                case ("booleanValue", let value as Bool):
                    returnExpression = Expression.boolean(value)
                case ("date", let value as Date):
                    returnExpression = Expression.date(value)
                case ("doubleValue", let value as Double):
                    returnExpression = Expression.double(value)
                case ("floatValue", let value as Float):
                    returnExpression = Expression.float(value)
                case ("intValue", let value as Int):
                    returnExpression = Expression.int(value)
                case ("string", let value as String):
                    returnExpression = Expression.string(value)
                case ("value", let value):
                    returnExpression = Expression.value(value)
                default:
                    break
                }
            }
        }
        
        return returnExpression!
    }
}

private class QueryMap {
    private var queryMap: Dictionary<String, Any>
    var selectDistinct = false
    var hasSelectResult = false
    var selectResult: Array<Array<Dictionary<String, Any>>> = []
    var hasFrom = false
    var from: Dictionary<String, Any>?
    var hasJoins = false
    var joins: Array<Dictionary<String, Any>> = []
    var hasWhere = false
    var mWhere: Array<Dictionary<String, Any>> = []
    var hasGroupBy = false
    var groupBy: Array<Dictionary<String, Any>> = []
    var hasOrderBy = false
    var orderBy: Array<Array<Dictionary<String, Any>>> = []
    var hasLimit = false
    var limit: Array<Dictionary<String, Any>> = []
    
    init(jsonObject: Any) {
        switch jsonObject {
        case let object as Dictionary<String, Any>:
            queryMap = object
        default:
            queryMap = Dictionary<String,Any>()
        }
        
        if let _selectDistinct = queryMap["selectDistinct"] as? Bool {
            self.selectDistinct = _selectDistinct
        }
        if let _ = queryMap["selectResult"] {
            self.hasSelectResult = true
            self.selectResult = getListofList(key: "selectResult")
        }
        if let _ = queryMap["from"] {
            self.hasFrom = true
            self.from = getMap(key: "from")
        }
        if let _ = queryMap["joins"] {
            self.hasJoins = true
            self.joins = getList(key: "joins")
        }
        if let _ = queryMap["where"] {
            self.hasWhere = true
            self.mWhere = getList(key: "where")
        }
        if let _ = queryMap["groupBy"] {
            self.hasGroupBy = true
            self.groupBy = getList(key: "groupBy")
        }
        if let _ = queryMap["orderBy"] {
            self.hasOrderBy = true
            self.orderBy = getListofList(key: "orderBy")
        }
        if let _ = queryMap["limit"] {
            self.hasLimit = true
            self.limit = getList(key: "limit")
        }
    }
    
    static func getListOfMapFromGenericList(objectList: Any) -> Array<Dictionary<String, Any>> {
        var resultList: Array<Dictionary<String, Any>> = []
        if let tempList = objectList as? Array<Any> {
            for listObject in tempList {
                resultList.append(QueryMap.getMapFromGenericMap(objectMap: listObject))
            }
        }
        
        return resultList
    }
    
    private static func getMapFromGenericMap(objectMap: Any) -> Dictionary<String, Any> {
        var resultMap = Dictionary<String, Any>()
        
        if let map = objectMap as? Dictionary<String, Any> {
            for key in map.keys {
                resultMap[key] = map[key]
            }
        }
        
        return resultMap
    }
    
    private func getMap(key: String) -> Dictionary<String, Any>{
        var resultList: Array<Dictionary<String, Any>> = []
        if let tempList = queryMap[key] as? Array<Any> {
            for listObject in tempList {
                resultList.append(QueryMap.getMapFromGenericMap(objectMap: listObject))
            }
        }
        
        if let map = queryMap[key] {
            return QueryMap.getMapFromGenericMap(objectMap: map)
        }
        
        return Dictionary<String, Any>()
    }
    
    private func getList(key: String) -> Array<Dictionary<String, Any>>{
        var resultList: Array<Dictionary<String, Any>> = []
        if let tempList = queryMap[key] as? Array<Any> {
            for listObject in tempList {
                resultList.append(QueryMap.getMapFromGenericMap(objectMap: listObject))
            }
        }
        
        return resultList
    }
    
    private func getListofList(key: String) -> Array<Array<Dictionary<String, Any>>> {
        var resultOuterList: Array<Array<Dictionary<String, Any>>> = []
        if let outerObjectList = queryMap[key] as? Array<Any> {
            for innerListObject in outerObjectList {
                resultOuterList.append(QueryMap.getListOfMapFromGenericList(objectList: innerListObject))
            }
        }
        
        return resultOuterList
    }
    
    private func getString(key: String) -> String? {
        return queryMap[key] as? String
    }
}
