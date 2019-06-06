package it.oltrenuovefrontiere.fluttercouch;

import com.couchbase.lite.DataSource;
import com.couchbase.lite.Expression;
import com.couchbase.lite.From;
import com.couchbase.lite.GroupBy;
import com.couchbase.lite.Join;
import com.couchbase.lite.Joins;
import com.couchbase.lite.Meta;
import com.couchbase.lite.MetaExpression;
import com.couchbase.lite.OrderBy;
import com.couchbase.lite.Ordering;
import com.couchbase.lite.PropertyExpression;
import com.couchbase.lite.Query;
import com.couchbase.lite.QueryBuilder;
import com.couchbase.lite.ResultSet;
import com.couchbase.lite.Select;
import com.couchbase.lite.SelectResult;
import com.couchbase.lite.Where;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.JSONUtil;

class QueryJson {
    private QueryMap queryMap;
    private Query query = null;
    private CBManager mCBManager;

    QueryJson(JSONObject json, CBManager manager) {
        this.mCBManager = manager;
        this.queryMap = new QueryMap(json);
    }

    static List<Map<String,Object>> resultsToJson(ResultSet results) {
        List<Map<String,Object>> rtnList = new ArrayList<>();
        for (final com.couchbase.lite.Result rslt:results) {
            HashMap<String, Object> value = new HashMap<>();
            value.put("map",rslt.toMap());
            value.put("list",rslt.toList());
            rtnList.add(value);
        }

        return rtnList;
    }

    Query toCouchbaseQuery() {
        if (queryMap.hasSelectResult) {
            inflateSelect();
        }
        if (queryMap.hasFrom) {
            inflateFrom();
        }
        if (queryMap.hasJoins) {
            inflateJoins();
        }
        if (queryMap.hasWhere) {
            inflateWhere();
        }
        if (queryMap.hasOrderBy) {
            inflateOrderBy();
        }
        if (queryMap.hasGroupBy) {
            inflateGroupBy();
        }
        if (queryMap.hasLimit) {
            inflateLimit();
        }
        return query;
    }

    private void inflateLimit() {
        List<Map<String, Object>> limitArray = queryMap.limit;
        if (limitArray.size() == 1) {
            Expression limitExpression = inflateExpressionFromArray(limitArray);
            if (query instanceof From) {
                query = ((From) query).limit(limitExpression);
            } else if (query instanceof Joins) {
                query = ((Joins) query).limit(limitExpression);
            } else if (query instanceof Where) {
                query = ((Where) query).limit(limitExpression);
            } else if (query instanceof OrderBy) {
                query = ((OrderBy) query).limit(limitExpression);
            } else if (query instanceof GroupBy) {
                query = ((GroupBy) query).limit(limitExpression);
            }
        } else if (limitArray.size() == 2) {
            Expression limitExpression = inflateExpressionFromArray(limitArray.subList(0, 0));
            Expression offsetExpression = inflateExpressionFromArray(limitArray.subList(1, 1));
            if (query instanceof From) {
                query = ((From) query).limit(limitExpression, offsetExpression);
            } else if (query instanceof Joins) {
                query = ((Joins) query).limit(limitExpression, offsetExpression);
            } else if (query instanceof Where) {
                query = ((Where) query).limit(limitExpression, offsetExpression);
            } else if (query instanceof OrderBy) {
                query = ((OrderBy) query).limit(limitExpression, offsetExpression);
            } else if (query instanceof GroupBy) {
                query = ((GroupBy) query).limit(limitExpression, offsetExpression);
            }
        }
    }

    private void inflateGroupBy() {
        List<Map<String, Object>> groupByArray = queryMap.groupBy;
        if (query instanceof From) {
            query = ((From) query).groupBy(inflateGrouping(groupByArray));
        } else if (query instanceof Where) {
            query = ((Where) query).groupBy(inflateGrouping(groupByArray));
        }
    }

    private Expression[] inflateGrouping(List<Map<String, Object>> groupByArray) {
        List<Expression> groupingArray = new ArrayList<>();
        // The currentGroupByExpression has to be wrapped in an array in order to be passed as an argument to inflateExpressionFromArray.
        // groupingArray cannot be passed directly to inflateExpressionFromArray because the desired result is not a unique inflated expression,
        // but an array containing the corresponding inflated expression for each index.
        for (Map<String, Object> currentGroupByExpression : groupByArray) {
            List<Map<String, Object>> currentGroupByExpressionInArray = new ArrayList<>();
            currentGroupByExpressionInArray.add(currentGroupByExpression);
            groupingArray.add(inflateExpressionFromArray(currentGroupByExpressionInArray));
        }
        return groupingArray.toArray(new Expression[0]);
    }

    private void inflateOrderBy() {
        List<List<Map<String, Object>>> orderByArray = queryMap.orderBy;
        if (query instanceof From) {
            query = ((From) query).orderBy(inflateOrdering(orderByArray));
        } else if (query instanceof Joins) {
            query = ((Joins) query).orderBy(inflateOrdering(orderByArray));
        } else if (query instanceof Where) {
            query = ((Where) query).orderBy(inflateOrdering(orderByArray));
        }
    }

    private Ordering[] inflateOrdering(List<List<Map<String, Object>>> orderByArray) {
        List<Ordering> resultOrdering = new ArrayList<>();
        for (List<Map<String, Object>> currentOrderByArgument : orderByArray) {
            Map<String,Object> last = currentOrderByArgument.get(currentOrderByArgument.size() -1);
            Expression orderingExpression = inflateExpressionFromArray(currentOrderByArgument);
            Ordering.SortOrder ordering = Ordering.expression(orderingExpression);

            if (last.containsKey("orderingSortOrder")) {
                String orderingSortOrder = (String) last.get("orderingSortOrder");
                if (orderingSortOrder.equals("ascending")) {
                    resultOrdering.add(ordering.ascending());
                } else if (orderingSortOrder.equals("descending")) {
                    resultOrdering.add(ordering.descending());
                }
            } else {
                resultOrdering.add(ordering);
            }
        }
        return resultOrdering.toArray(new Ordering[0]);
    }

    private void inflateJoins() {
        List<Map<String, Object>> joinsArray = queryMap.joins;
        Map<String, Object> joinArguments = joinsArray.get(0);
        String alias = (String) joinArguments.get("as");

        String databaseName;
        Join join;
        if (joinArguments.containsKey("join")) {
            databaseName = (String) joinArguments.get("join");
            if (alias != null) {
                join = Join.join(getDatasourceFromString(databaseName,alias));
            } else {
                join = Join.join(getDatasourceFromString(databaseName));
            }
        } else if (joinArguments.containsKey("crossJoin")) {
            databaseName = (String) joinArguments.get("crossJoin");
            if (alias != null) {
                join = Join.crossJoin(getDatasourceFromString(databaseName,alias));
            } else {
                join = Join.crossJoin(getDatasourceFromString(databaseName));
            }
        } else if (joinArguments.containsKey("innerJoin")) {
            databaseName = (String) joinArguments.get("innerJoin");
            if (alias != null) {
                join = Join.innerJoin(getDatasourceFromString(databaseName,alias));
            } else {
                join = Join.innerJoin(getDatasourceFromString(databaseName));
            }
        } else if (joinArguments.containsKey("leftJoin")) {
            databaseName = (String) joinArguments.get("leftJoin");
            if (alias != null) {
                join = Join.leftJoin(getDatasourceFromString(databaseName,alias));
            } else {
                join = Join.leftJoin(getDatasourceFromString(databaseName));
            }
        } else if (joinArguments.containsKey("leftOuterJoin")) {
            databaseName = (String) joinArguments.get("leftOuterJoin");
            if (alias != null) {
                join = Join.leftOuterJoin(getDatasourceFromString(databaseName,alias));
            } else {
                join = Join.leftOuterJoin(getDatasourceFromString(databaseName));
            }
        } else {
            return;
        }

        if (joinsArray.size() == 1) {
            query = ((From) query).join(join);
        } else if (joinsArray.size() == 2) {
            Map<String, Object> joinOnArguments = joinsArray.get(1);
            Expression onExpression = inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(joinOnArguments.get("on")));
            query = ((From) query).join(((Join.On) join).on(onExpression));
        }
    }

    private void inflateFrom() {
        String databaseName = (String) queryMap.from.get("database");
        String alias = (String) queryMap.from.get("as");

        if (alias != null) {
            query = ((Select) query).from(getDatasourceFromString(databaseName,alias));
        } else {
            query = ((Select) query).from(getDatasourceFromString(databaseName));
        }
    }

    private void inflateSelect() {
        boolean selectDistinct = queryMap.selectDistinct;
        if (selectDistinct) {
            query = QueryBuilder.selectDistinct(inflateSelectResultArray());
        } else {
            query = QueryBuilder.select(inflateSelectResultArray());
        }
    }

    private DataSource getDatasourceFromString(String name) {
        return DataSource.database(mCBManager.getDatabase(name));
    }

    private DataSource getDatasourceFromString(String name, String as) {
        return DataSource.database(mCBManager.getDatabase(name)).as(as);
    }

    private SelectResult[] inflateSelectResultArray() {
            List<List<Map<String, Object>>> selectResultArray = queryMap.selectResult;
            List<SelectResult> result = new ArrayList<>();
            for (List<Map<String, Object>> SelectResultParametersArray : selectResultArray) {
                result.add(inflateSelectResult(SelectResultParametersArray));
            }
        return result.toArray(new SelectResult[0]);
    }

    private SelectResult inflateSelectResult(List<Map<String, Object>> selectResultParametersArray) {
        SelectResult.As result = SelectResult.expression(inflateExpressionFromArray(selectResultParametersArray));

        String alias = (String) selectResultParametersArray.get(selectResultParametersArray.size()-1).get("as");
        if (alias != null) {
            return result.as(alias);
        }

        return result;
    }

    private void inflateWhere() {
        List<Map<String, Object>> whereObject = queryMap.where;
        if (query instanceof From) {
            query = ((From) query).where(inflateExpressionFromArray(whereObject));
        } else if (query instanceof Joins) {
            query = ((Joins) query).where(inflateExpressionFromArray(whereObject));
        }
    }

    private Expression inflateExpressionFromArray(List<Map<String, Object>> expressionParametersArray) {
        Expression returnExpression = null;
        for (int i = 0; i <= expressionParametersArray.size() - 1; i++) {
            Map<String, Object> currentExpression = expressionParametersArray.get(i);
            if (returnExpression == null) {
                switch (currentExpression.keySet().iterator().next()) {
                    case ("property"):
                        Object value = currentExpression.get("property");
                        if (value == null) {
                            returnExpression = Expression.all();
                        } else {
                            returnExpression = Expression.property(((String) value));
                        }
                        break;
                    case ("meta"):
                        if (currentExpression.get("meta").equals("id")) {
                            returnExpression = Meta.id;
                        } else if (currentExpression.get("meta").equals("sequence")) {
                            returnExpression = Meta.sequence;
                        }
                        break;
                    case ("booleanValue"):
                        returnExpression = Expression.booleanValue((Boolean) currentExpression.get("booleanValue"));
                        break;
                    case ("date"):
                        returnExpression = Expression.date((Date) currentExpression.get("date"));
                        break;
                    case ("doubleValue"):
                        returnExpression = Expression.doubleValue((double) currentExpression.get("doubleValue"));
                        break;
                    case ("floatValue"):
                        returnExpression = Expression.floatValue((float) currentExpression.get("floatValue"));
                        break;
                    case ("intValue"):
                        returnExpression = Expression.intValue((int) currentExpression.get("intValue"));
                        break;
                    case ("longValue"):
                        returnExpression = Expression.longValue((long) currentExpression.get("longValue"));
                        break;
                    case ("string"):
                        returnExpression = Expression.string((String) currentExpression.get("string"));
                        break;
                    case ("value"):
                        returnExpression = Expression.value(currentExpression.get("value"));
                        break;
                }
            } else {
                switch (currentExpression.keySet().iterator().next()) {
                    case ("from"):
                        if (returnExpression instanceof PropertyExpression) {
                            returnExpression = ((PropertyExpression) returnExpression).from((String) currentExpression.get("from"));
                        } else if (returnExpression instanceof MetaExpression) {
                            returnExpression = ((MetaExpression) returnExpression).from((String) currentExpression.get("from"));
                        }
                        break;
                    case ("add"):
                        returnExpression = returnExpression.add(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("add"))));
                        break;
                    case ("and"):
                        returnExpression = returnExpression.and(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("and"))));
                        break;
                    case ("divide"):
                        returnExpression = returnExpression.divide(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("divide"))));
                        break;
                    case ("equalTo"):
                        returnExpression = returnExpression.equalTo(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("equalTo"))));
                        break;
                    case ("greaterThan"):
                        returnExpression = returnExpression.greaterThan(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("greaterThan"))));
                        break;
                    case ("greaterThanOrEqualTo"):
                        returnExpression = returnExpression.greaterThanOrEqualTo(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("greaterThanOrEqualTo"))));
                        break;
                    case ("is"):
                        returnExpression = returnExpression.is(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("is"))));
                        break;
                    case ("isNot"):
                        returnExpression = returnExpression.isNot(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("isNot"))));
                        break;
                    case ("isNullOrMissing"):
                        returnExpression = returnExpression.isNullOrMissing();
                        break;
                    case ("lessThan"):
                        returnExpression = returnExpression.lessThan(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("lessThan"))));
                        break;
                    case ("lessThanOrEqualTo"):
                        returnExpression = returnExpression.lessThanOrEqualTo(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("lessThanOrEqualTo"))));
                        break;
                    case ("like"):
                        returnExpression = returnExpression.like(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("like"))));
                        break;
                    case ("modulo"):
                        returnExpression = returnExpression.modulo(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("modulo"))));
                        break;
                    case ("multiply"):
                        returnExpression = returnExpression.multiply(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("multiply"))));
                        break;
                    case ("notEqualTo"):
                        returnExpression = returnExpression.notEqualTo(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("notEqualTo"))));
                        break;
                    case ("notNullOrMissing"):
                        returnExpression = returnExpression.notNullOrMissing();
                        break;
                    case ("or"):
                        returnExpression = returnExpression.or(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("or"))));
                        break;
                    case ("regex"):
                        returnExpression = returnExpression.regex(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("regex"))));
                        break;
                    case ("subtract"):
                        returnExpression = returnExpression.subtract(inflateExpressionFromArray(QueryMap.getListOfMapFromGenericList(currentExpression.get("subtract"))));
                        break;
                }
            }
        }
        return returnExpression;
    }
}

class QueryMap {
    private Map<String, Object> queryMap;
    boolean selectDistinct = false;
    boolean hasSelectResult = false;
    List<List<Map<String, Object>>> selectResult = new ArrayList<>();
    boolean hasFrom = false;
    Map<String, Object> from;
    boolean hasJoins = false;
    List<Map<String, Object>> joins = new ArrayList<>();
    boolean hasWhere = false;
    List<Map<String, Object>> where = new ArrayList<>();
    boolean hasGroupBy = false;
    List<Map<String, Object>> groupBy = new ArrayList<>();
    boolean hasOrderBy = false;
    List<List<Map<String, Object>>> orderBy = new ArrayList<>();
    boolean hasLimit = false;
    List<Map<String, Object>> limit = new ArrayList<>();

    QueryMap(JSONObject jsonObject) {
        Object unwrappedJson = JSONUtil.unwrap(jsonObject);
        if (unwrappedJson instanceof Map<?, ?>) {
            this.queryMap = getMapFromGenericMap(unwrappedJson);
        }
        if (queryMap.containsKey("selectDistinct")) {
            this.selectDistinct = (Boolean) queryMap.get("selectDistinct");
        }
        if (queryMap.containsKey("selectResult")) {
            this.hasSelectResult = true;
            this.selectResult = getListofList("selectResult");
        }
        if (queryMap.containsKey("from")) {
            this.hasFrom = true;
            this.from = getMap("from");
        }
        if (queryMap.containsKey("joins")) {
            this.hasJoins = true;
            this.joins = getList("joins");
        }
        if (queryMap.containsKey("where")) {
            this.hasWhere = true;
            this.where = getList("where");
        }
        if (queryMap.containsKey("groupBy")) {
            this.hasGroupBy = true;
            this.groupBy = getList("groupBy");
        }
        if (queryMap.containsKey("orderBy")) {
            this.hasOrderBy = true;
            this.orderBy = getListofList("orderBy");
        }
        if (queryMap.containsKey("limit")) {
            this.hasLimit = true;
            this.limit = getList("limit");
        }

    }

    static List<Map<String, Object>> getListOfMapFromGenericList(Object objectList) {
        List<Map<String, Object>> resultList = new ArrayList<>();
        if (objectList instanceof List<?>) {
            List<?> genericList = (List<?>) objectList;
            for (Object listObject : genericList) {
                if (listObject instanceof Map<?, ?>) {
                    resultList.add(getMapFromGenericMap(listObject));
                }
            }
        }
        return resultList;
    }

    private static Map<String, Object> getMapFromGenericMap(Object objectMap) {
        Map<String, Object> resultMap = new HashMap<>();
        if (objectMap instanceof Map<?, ?>) {
            Map<?,?> genericMap = (Map<?,?>) objectMap;
            for (Map.Entry<?, ?> entry : genericMap.entrySet()) {
                resultMap.put((String) entry.getKey(), entry.getValue());
            }
        }
        return resultMap;
    }

    private List<Map<String, Object>> getList(String key) {
        List<?> tempList = (List<?>) queryMap.get(key);
        List<Map<String, Object>> resultList = new ArrayList<>();
        for (Object listObject : tempList) {
            if (listObject instanceof Map<?, ?>) {
                resultList.add(getMapFromGenericMap(listObject));
            }
        }
        return resultList;
    }

    private Map<String, Object> getMap(String key) {
        Object mapObject = queryMap.get(key);
        if (mapObject instanceof Map<?, ?>) {
            return getMapFromGenericMap(mapObject);
        }

        return new HashMap<>();
    }

    private List<List<Map<String, Object>>> getListofList(String key) {
        List<List<Map<String, Object>>> resultOuterList = new ArrayList<>();
        Object objectList = queryMap.get(key);
        if (objectList instanceof List<?>) {
            List<?> outerObjectList = (List<?>) objectList;
            for (Object innerListObject : outerObjectList) {
                resultOuterList.add(getListOfMapFromGenericList(innerListObject));
            }
        }
        return resultOuterList;
    }

    private String getString(String key) {
        String result = null;
        Object value = queryMap.get(key);
        if (value instanceof String) {
            result = (String) value;
        }
        return result;
    }
}
