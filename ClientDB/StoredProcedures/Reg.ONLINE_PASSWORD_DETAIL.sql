USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[ONLINE_PASSWORD_DETAIL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Reg].[ONLINE_PASSWORD_DETAIL]  AS SELECT 1')
GO
ALTER PROCEDURE [Reg].[ONLINE_PASSWORD_DETAIL]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT
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

		SELECT
			SystemShortName AS [Система], PASS AS [Пароль],
			CASE STATUS WHEN 1 THEN 'Действующий' WHEN 2 THEN 'Старый' WHEN 3 THEN 'Удален' ELSE '???' END AS [Статус],
			UPD_DATE AS [Дата установки пароля], UPD_USER AS [Пользователь]
		FROM
			Reg.OnlinePassword a
			INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
		WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP
		ORDER BY UPD_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Reg].[ONLINE_PASSWORD_DETAIL] TO rl_reg_online;
GO
