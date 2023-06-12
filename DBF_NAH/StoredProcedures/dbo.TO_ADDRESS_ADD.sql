USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_ADDRESS_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_ADDRESS_ADD]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:	  Добавить сотрудника клиенту
*/

ALTER PROCEDURE [dbo].[TO_ADDRESS_ADD]
	@toid INT,
	@streetid SMALLINT,
	@index VARCHAR(20),
	@home VARCHAR(100),
	@returnvalue BIT = 1
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

		INSERT INTO dbo.TOAddressTable(
									TA_ID_TO, TA_INDEX, TA_ID_STREET, TA_HOME
									)
		VALUES (
				@toid, @index, @streetid, @home
				)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_ADDRESS_ADD] TO rl_client_w;
GO
