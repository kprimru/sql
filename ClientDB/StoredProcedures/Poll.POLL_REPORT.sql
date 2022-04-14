USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Poll].[POLL_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Poll].[POLL_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Poll].[POLL_REPORT]
    @Blank_Id   UniqueIdentifier,
    @Service_Id Int = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @SQL            NVarChar(Max);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        IF Object_Id('tempdb..#Clients') IS NOT NULL
            DROP TABLE #Clients;

        CREATE TABLE #Clients
        (
            [Client_Id]         Int                 NOT NULL,
            [RowNumber]         SmallInt            NOT NULL,
            [ClientFullName]    VarChar(512)        NOT NULL,
            [Blank_Id]          UniqueIdentifier        NULL,
            [BlankDate]         SmallDateTime           NULL,
            [CallNote]          VarChar(Max)            NULL,
			[CallPersonal]		VarChar(250)			NULL,
            PRIMARY KEY CLUSTERED([Client_Id])
        );

        INSERT INTO #Clients
        SELECT
            C.[ClientID],
            Row_Number() OVER(ORDER BY [ClientFullName]),
            C.[ClientFullName],
            P.[ID],
            P.[DATE],
            P.[CC_NOTE],
			P.[CC_PERSONAL]
        FROM [dbo].[ClientView]                     AS C WITH(NOEXPAND)
        INNER JOIN [dbo].[ServiceStatusConnected]() AS S ON S.[ServiceStatusId] = C.[ServiceStatusID]
        CROSS APPLY
        (
            SELECT TOP (1)
                P.[ID],
                P.[DATE],
                CC.[CC_NOTE],
				CC.[CC_PERSONAL]
            FROM [Poll].[ClientPoll]        AS P
            INNER JOIN [dbo].[ClientCall]   AS CC ON CC.[CC_ID] = P.[ID_CALL]
            WHERE P.[ID_CLIENT] = C.[ClientID]
                AND P.[ID_BLANK] = @Blank_Id
            ORDER BY DATE DESC
        ) AS P
        WHERE C.[ServiceID] = @Service_Id
        ORDER BY C.[ClientFullName];

        SET @SQL = 'SELECT C.[Client_Id], C.[RowNumber], C.[ClientFullName], C.[BlankDate], '

        SELECT @SQL = @SQL +
            CASE Q.[TP]
                -- однозначный ответ
                WHEN 0 THEN
        '
        (
            SELECT A.[NAME]
            FROM [Poll].[ClientPollQuestion]        AS CPQ
            INNER JOIN [Poll].[ClientPollAnswer]    AS CPA  ON CPA.[ID_QUESTION] = CPQ.[ID]
            INNER JOIN [Poll].[Answer]              AS A    ON A.[ID] = CPA.[ID_ANSWER]
            WHERE CPQ.[ID_POLL] = C.[Blank_Id]
                AND CPQ.[ID_QUESTION] = ''' + Cast(Q.[ID] AS VarChar(Max)) + '''
        ) AS [' + Q.[NAME] + '],'
                WHEN 1 THEN
        '
        (
            SELECT Reverse(Stuff(Reverse(A.[NAME] + CHAR(13)+CHAR(10)), 1, 2, ''''))
            FROM [Poll].[ClientPollQuestion]        AS CPQ
            INNER JOIN [Poll].[ClientPollAnswer]    AS CPA  ON CPA.[ID_QUESTION] = CPQ.[ID]
            INNER JOIN [Poll].[Answer]              AS A    ON A.[ID] = CPA.[ID_ANSWER]
            WHERE CPQ.[ID_POLL] = C.[Blank_Id]
                AND CPQ.[ID_QUESTION] = ''' + Cast(Q.[ID] AS VarChar(Max)) + '''
            ORDER BY A.[ORD] FOR XML PATH('''')
        ) AS [' + Q.[NAME] + '],'
        WHEN 2 THEN
        '
        (
            SELECT CPA.[TEXT_ANSWER]
            FROM [Poll].[ClientPollQuestion]        AS CPQ
            INNER JOIN [Poll].[ClientPollAnswer]    AS CPA  ON CPA.[ID_QUESTION] = CPQ.[ID]
            WHERE CPQ.[ID_POLL] = C.[Blank_Id]
                AND CPQ.[ID_QUESTION] = ''' + Cast(Q.[ID] AS VarChar(Max)) + '''
        ) AS [' + Q.[NAME] + '],'
        WHEN 3 THEN
        '
        (
            SELECT CPA.[INT_ANSWER]
            FROM [Poll].[ClientPollQuestion]        AS CPQ
            INNER JOIN [Poll].[ClientPollAnswer]    AS CPA  ON CPA.[ID_QUESTION] = CPQ.[ID]
            WHERE CPQ.[ID_POLL] = C.[Blank_Id]
                AND CPQ.[ID_QUESTION] = ''' + Cast(Q.[ID] AS VarChar(Max)) + '''
        ) AS [' + Q.[NAME] + '],'
            END
        --FROM SELECT Q.[TP], Q.[NAME]
        FROM [Poll].[Question]      AS Q
        WHERE Q.[ID_BLANK] = @Blank_Id
        --ORDER BY Q.[ORD];

        --SET @SQL = Left(@SQL, Len(@SQL) - 1)

        SET @SQL = @SQL + ' C.[CallNote], C.[CallPersonal]
        FROM #Clients AS C'

        SET @SQL = @SQL + '
        ORDER BY [ClientFullName]';


        EXEC (@SQL)


        IF Object_Id('tempdb..#Clients') IS NOT NULL
            DROP TABLE #Clients;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Poll].[POLL_REPORT] TO rl_blank_report;
GO
