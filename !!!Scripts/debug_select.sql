--/*
SELECT
	[ProcedureName] 	= O.[Object],
	[AvgDelta]			= Avg(O.[Delta]),
	[MaxDelta]			= Max(O.[Delta]),
	[MinDelta]			= Min(O.[Delta]),
	[ExecutionCount]	= Count(*)
FROM
(
	SELECT [Object], [Delta] = DateDiff(ms, S.[StartDateTime], F.[FinishDateTime])
	FROM [Debug].[Executions:Start]			AS S	WITH(NOLOCK)	
	INNER JOIN [Debug].[Executions:Finish]	AS F	WITH(NOLOCK)	ON	S.[Id] = F.[Id]
	WHERE S.[StartDateTime] >= '20200311'
		-- �������� ������ ������� �����, ����� ������ �������� ������� �� ������� ����������
		--AND DatePart(HOUR, S.[StartDateTime]) BETWEEN 8 AND 19
		--AND [Object] LIKE '^[Report^].%' ESCAPE '^'
		--AND S.[UserName] = 'boss'
) AS O
GROUP BY O.[Object]
ORDER BY
	--[ExecutionCount] DESC
	--, 
	[AvgDelta] DESC
--/*

/*
EXEC [Debug].[Executions@Read]
    @Object = '[Report].[HOTLINE_CLIENT_REPORT]';
    
EXEC [Debug].[Executions@Read]
    @Exec_Id = 6155472
*/

/*
SELECT [Object], [Delta], [Cnt] = Count(*)
FROM
(
	SELECT [Object], [Delta] = DateDiff(ms, S.[StartDateTime], F.[FinishDateTime])
	FROM [Debug].[Executions:Start]			AS S	WITH(NOLOCK)	
	INNER JOIN [Debug].[Executions:Finish]	AS F	WITH(NOLOCK)	ON	S.[Id] = F.[Id]
	WHERE S.[Object] LIKE  '%REG_SUBHOST_SELECT%'
		--AND S.[StartDateTime] >= '20200302'
) AS O	
GROUP BY O.[Object], O.[Delta]
ORDER BY
	--[Cnt] DESC
	[Delta] DESC
--*/

/*
SELECT [Object], [Delta], [StartDateTime]
FROM
(
	SELECT S.[StartDateTime], [Object], [Delta] = DateDiff(ms, S.[StartDateTime], F.[FinishDateTime])
	FROM [Debug].[Executions:Start]			AS S	WITH(NOLOCK)	
	INNER JOIN [Debug].[Executions:Finish]	AS F	WITH(NOLOCK)	ON	S.[Id] = F.[Id]
	WHERE S.[Object] = '[dbo].[EXPERT_QUESTION_LOAD]'
		--AND S.[StartDateTime] >= '20200302'
) AS O	
--GROUP BY O.[Object], O.[Delta]
ORDER BY
	--[Cnt] DESC
	--[Delta] DESC
	[StartDateTime] DESC
--*/

/*	
SELECT [Object], S.[StartDateTime], F.[Error], S.[UserName], [Duration] = -DateDiff(Second, F.[FinishDateTime], S.[StartDateTime])
FROM [Debug].[Executions:Start]			AS S	WITH(NOLOCK)	
INNER JOIN [Debug].[Executions:Finish]	AS F	WITH(NOLOCK)	ON	S.[Id] = F.[Id]
WHERE [StartDateTime] >= '2021-08-13T10:33:59.783'
    AND [StartDateTime] <= '2021-08-13T10:46:13.847'
    
    
    --F.[Error] IS NOT NULL
	--AND S.[Object] != '[dbo].[CONTROL_DOCUMENT_LOAD]'
ORDER BY S.[StartDateTime] DESC
--*/	



/*
SELECT '[' + S.[name] + '].[' + O.[name] + ']' 
FROM [sys].[objects]		AS O
INNER JOIN [sys].[schemas]	AS S ON O.[schema_id] = S.[schema_id]
WHERE O.type = 'P'
	AND OBJECT_DEFINITION(O.[object_id]) NOT LIKE '%EXEC ^[Debug^].^[Execution@Start^]%' ESCAPE '^'
	AND O.[name] NOT LIKE 'dt[_]%'
	AND O.[name] NOT LIKE 'sp[_]%'
	AND O.[name] NOT IN ('Execution@Finish', 'Execution@Start', 'ReRaise Error')
ORDER BY S.[name], O.[name]
--*/

/*
TRUNCATE TABLE [Debug].[Executions:Point:Params]
TRUNCATE TABLE [Debug].[Executions:Start:Params]
TRUNCATE TABLE [Debug].[Executions:Point]
TRUNCATE TABLE [Debug].[Executions:Finish]
TRUNCATE TABLE [Debug].[Executions:Start]
--*/