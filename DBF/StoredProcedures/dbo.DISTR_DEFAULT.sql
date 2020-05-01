USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:	  
*/

ALTER PROCEDURE [dbo].[DISTR_DEFAULT] 
	@sysid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF (SELECT SYS_SHORT_NAME FROM dbo.SystemTable WHERE SYS_ID = @sysid) IN ('ГК', 'Флэш', 'Yubikey', 'Лицензия', 'ЭГК')
			SELECT ISNULL(
				(
					SELECT MAX(DIS_NUM) + 1 AS DIS_NUM
					FROM dbo.DistrTable
					WHERE DIS_ID_SYSTEM = @sysid
				), 1000) AS DIS_NUM
		ELSE
			SELECT NULL AS DIS_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DISTR_DEFAULT] TO rl_distr_r;
GO