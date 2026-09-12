CREATE OR REPLACE PROCEDURE public.sp_approval_work_flow_filter(
    _searchstring character varying, 
    _sortby character varying, 
    _pageindex integer, 
    _pagesize integer,
    INOUT _cursor refcursor DEFAULT 'ref_result'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _selectquery TEXT;
    _condition TEXT;
    _offset integer;
BEGIN
    -- Set default sorting
    IF (_sortby IS NULL OR TRIM(_sortby) = '') THEN
        _sortby := 'updatedon DESC NULLS LAST, createdon DESC';
    END IF;

    -- Set default search condition
    _condition := COALESCE(NULLIF(TRIM(_searchstring), ''), '1=1');

    -- Safe default pagination
    _pageindex := COALESCE(NULLIF(_pageindex, 0), 1);
    _pagesize := COALESCE(NULLIF(_pagesize, 0), 10);
    _offset := (_pageindex - 1) * _pagesize;

    _selectquery := '
        SELECT 
            ROW_NUMBER() OVER (ORDER BY ' || _sortby || ') AS rowindex,
            w.approvalworkflowid,
            w.title,
            w.titledescription,
            w.status,
            w.createdby,
            w.createdon,
            w.updatedby,
            w.updatedon,
            COUNT(1) OVER() AS total
        FROM approval_work_flow w
        WHERE ' || _condition || '
        ORDER BY ' || _sortby || '
        LIMIT ' || _pagesize || ' OFFSET ' || _offset;

    OPEN _cursor FOR EXECUTE _selectquery;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_approval_work_flow_filter'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$;
