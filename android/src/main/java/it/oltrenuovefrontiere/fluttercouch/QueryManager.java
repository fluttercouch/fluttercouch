package it.oltrenuovefrontiere.fluttercouch;

import com.couchbase.lite.DataSource;
import com.couchbase.lite.Expression;
import com.couchbase.lite.Query;
import com.couchbase.lite.QueryBuilder;
import com.couchbase.lite.Select;
import com.couchbase.lite.SelectResult;

import java.util.HashMap;

public class QueryManager {
    static Query buildFromMap(HashMap<String, String> _map, CBManager _cbManager) {
        if (_map == null && _map.isEmpty()) {
            return null;
        }
        QueryFromMap result = new QueryFromMap(_map, _cbManager);

        return result.getQuery();
    }

    //property<type>|equalTo(string<SDK>|)|
    static Expression getExpressionFromString(String _expressionString) {
        Expression _nullExpression = Expression.string("___null___");
        Expression _result = _nullExpression;
        String[] _expressions = _expressionString.split("\\|");
        for (String _commandString : _expressions) {
            Expression _constructedExpression;
            HashMap<String, String> splittedCommand = getSelectorArgument(_commandString);
            switch (splittedCommand.get("selector")) {
                case ("property"):
                    _constructedExpression = Expression.property(splittedCommand.get("argument"));
                    break;
                case ("equalTo"):
                    _result.equalTo(QueryManager.getExpressionFromString(splittedCommand.get("argument")));
                    _constructedExpression = _nullExpression;
                    break;
                case ("string"):
                    _constructedExpression = Expression.string(splittedCommand.get("argument"));
                    break;
                default:
                    _constructedExpression = _nullExpression;
            }
            if (_result == _nullExpression) {
                _result = _constructedExpression;
            } else {
                if (_constructedExpression != _nullExpression) {
                    _result.add(_constructedExpression);
                }
            }
        }
        return _result;
    }

    private static HashMap<String, String> getSelectorArgument(String _command) {
        HashMap<String, String> _result = new HashMap<>();
        String[] _string = _command.split("()<>");
        _result.put("selector", _string[0]);
        _result.put("argument", _string[1]);
        return _result;
    }

    private static class QueryFromMap {
        private HashMap<String, String> _internalMap;
        private Query _query;
        private CBManager _cbManager;

        QueryFromMap(HashMap<String, String> _map, CBManager _cbManager) {
            this._internalMap = _map;
            this._query = null;
            this._cbManager = _cbManager;
        }

        Query getQuery() {
            initialize();
            return _query;
        }

        private void initialize() {
            if (_internalMap.containsKey("selectDistinct") && _internalMap.get("selectDistinct").equals("true")) {
                _query = QueryBuilder.selectDistinct(getSelectResult());
            } else {
                _query = QueryBuilder.select(getSelectResult());
            }
            if (_internalMap.containsKey("databaseName")) {
                setFrom();
            }
            if (_internalMap.containsKey("where")) {
                setWhere();
            }
        }

        private SelectResult getSelectResult() {
            if (_internalMap.containsKey("selectResultsFromAll") && _internalMap.get("selectResultsFromAll").equals("true")) {
                return SelectResult.all();
            }
            return null;
        }

        private void setFrom() {
            if (_cbManager.getDatabase().getName() == _internalMap.get("databaseName")) {
                Select _selectQuery = (Select) this._query;
                _selectQuery.from(DataSource.database(_cbManager.getDatabase()));
                this._query = _selectQuery;
            }
        }

        private void setWhere() {
            String _whereClause = _internalMap.get("where");
            Expression _expression = QueryManager.getExpressionFromString(_whereClause);
        }


    }
}
