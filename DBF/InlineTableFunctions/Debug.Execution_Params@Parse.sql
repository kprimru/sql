USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Debug].[Execution:Params@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [Debug].[Execution:Params@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE   FUNCTION [Debug].[Execution:Params@Parse]
(
	@Params Xml
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[Row:Index] = 1,
		[Name]		= 'Name',
		[Value]		= 'Value'
	WHERE @Params IS NULL

	UNION ALL

	SELECT
        Row_Number() OVER(ORDER BY (SELECT 1)),
        v.value('@Name[1]', 'VarChar(256)'),
        v.value('@Value[1]', 'VarChar(Max)')
    FROM @Params.nodes('/PARAMS/PARAM') AS n(v)
)
GO
