USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[REG_LIST_PREPARE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Reg].[REG_LIST_PREPARE]  AS SELECT 1')
GO
ALTER PROCEDURE [Reg].[REG_LIST_PREPARE]
	@LST	NVARCHAR(MAX),
	@STATUS	BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @XML XML

		SET @XML = CAST(@LST AS XML)

		SELECT 1 AS TP,
			'Система;Номер дистрибутива;Номер компьютера;Тип;Технологический тип;Число станций;Подхост;Сделано переносов;Осталось переносов;Сопровождение;Дата регистрации;Комментарий;Комплект' AS ST

		UNION ALL

		SELECT 2 AS TP,
			SystemBaseName + ';' + CONVERT(VARCHAR(20), DistrNumber) + ';' + CONVERT(VARCHAR(20), CompNumber) + ';' +
			DistrType + ';' + TechnolType + ';' + CONVERT(VARCHAR(20), NetCount) + ';' +
			CONVERT(VARCHAR(20), Subhost) + ';' + Convert(VARCHAR(20), TransferCount) + ';' +
			CONVERT(VARCHAR(20), TransferLeft) + ';' +
			CASE @STATUS WHEN 1 THEN '0' ELSE '1' END
			--'LAW;20;1;NCT;0;50;0;13;3;0;22.04.2016;4232406605 Базис (Сетевой хост);LAW000020'
		FROM
			(
				SELECT
					c.value('(@hostid)', 'INT') AS HostID,
					c.value('(@distr)', 'INT') AS DISTR,
					c.value('(@comp)', 'TINYINT') AS COMP
				FROM @xml.nodes('/root/item') AS a(c)
			) AS a
			INNER JOIN dbo.SystemTable b ON a.HostID = b.HostID
			INNER JOIN dbo.RegNodeTable c ON c.SystemName = b.SystemBaseName AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
