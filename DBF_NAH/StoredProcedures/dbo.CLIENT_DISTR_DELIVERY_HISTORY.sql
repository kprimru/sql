USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:         Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_DELIVERY_HISTORY]
	@id INT,
	@clientid INT
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

		DECLARE @distrid INT

		SELECT @distrid = CD_ID_DISTR
		FROM dbo.ClientDistrTable
		WHERE CD_ID = @id

		UPDATE dbo.ClientDistrTable
		SET CD_ID_CLIENT = @clientid
		WHERE CD_ID = @id

		--удалить из ТО этот дистрибутив

		DELETE
		FROM dbo.TODistrTable
		WHERE TD_ID_DISTR =
			(
				SELECT CD_ID_DISTR
				FROM  dbo.ClientDistrTable
				WHERE CD_ID = @id
			)

		IF (SELECT COUNT(*) FROM dbo.TOTable WHERE TO_ID_CLIENT = @clientid) = 1
			BEGIN
				INSERT INTO dbo.TODistrTable (TD_ID_TO, TD_ID_DISTR)
				SELECT
					(
						SELECT TO_ID
						FROM dbo.TOTable
						WHERE TO_ID_CLIENT = @clientid
					),
					(
						SELECT CD_ID_DISTR
						FROM  dbo.ClientDistrTable
						WHERE CD_ID = @id
					)
			END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
