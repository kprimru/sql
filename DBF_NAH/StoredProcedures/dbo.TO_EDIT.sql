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

ALTER PROCEDURE [dbo].[TO_EDIT]
	@toid INT,
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
	@toparent	int = null,
	@range decimal(4,2) = NULL
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

		UPDATE dbo.TOTable
		SET
			TO_NAME = @toname,
			TO_NUM = @tonum,
			TO_REPORT = @toreport,
			TO_ID_COUR = @courid,
			TO_VMI_COMMENT = @vmi,
			TO_MAIN = @tomain,
			TO_INN = @toinn,
			TO_PARENT = @toparent,
			TO_RANGE = @range,
			TO_LAST = GETDATE()
		WHERE TO_ID = @toid

		IF @streetid IS NOT NULL
		BEGIN
			IF NOT EXISTS
				(
					SELECT *
					FROM dbo.TOAddressTable
					WHERE TA_ID_TO = @toid
				)
				INSERT INTO dbo.TOAddressTable(
										TA_ID_TO, TA_INDEX, TA_ID_STREET, TA_HOME
										)
				VALUES(
						@toid, @index, @streetid, @home
						)
			ELSE
				UPDATE dbo.TOAddressTable
				SET
					TA_INDEX = @index,
					TA_ID_STREET = @streetid,
					TA_HOME = @home
				WHERE TA_ID_TO = @toid
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
GRANT EXECUTE ON [dbo].[TO_EDIT] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_EDIT] TO rl_to_w;
GO
