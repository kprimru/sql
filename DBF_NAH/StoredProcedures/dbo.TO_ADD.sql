USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_ADD]
	@clientid INT,
	@toname VARCHAR(250),
	@tonum INT,
	@toreport BIT,
	@courid SMALLINT,
	@vmi VARCHAR(250),
	@index VARCHAR(20),
	@streetid SMALLINT,
	@home VARCHAR(200),
	@tomain BIT = 0,
	@toinn varchar(20) = null,
	@parent int = null,
	@range decimal(4,2) = NULL,
	@returnvalue BIT = 1
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

		DECLARE @toid INT

		INSERT INTO dbo.TOTable(
							TO_ID_CLIENT, TO_NAME, TO_NUM,
							TO_REPORT, TO_ID_COUR, TO_VMI_COMMENT, TO_MAIN, TO_INN, TO_PARENT, TO_RANGE
							)
		VALUES (
				@clientid, @toname, @tonum, @toreport, @courid, @vmi, @tomain, @toinn, @parent, @Range
				)

		SELECT @toid = SCOPE_IDENTITY()

		IF @streetid IS NOT NULL
		BEGIN
			INSERT INTO dbo.TOAddressTable(
										TA_ID_TO, TA_INDEX, TA_ID_STREET, TA_HOME
										)
			VALUES(
					@toid, @index, @streetid, @home
					)
		END

		IF @returnvalue = 1
			SELECT @toid AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TO_ADD] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_ADD] TO rl_to_w;
GO