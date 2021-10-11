USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_DOC_PROCESS]
	@distrid INT,
	@docid SMALLINT,
	@print BIT,
	@goodid SMALLINT,
	@unitid SMALLINT
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

		DECLARE @ddid INT

		SELECT @ddid = DD_ID
		FROM dbo.DistrDocumentTable
		WHERE DD_ID_DISTR = @distrid AND DD_ID_DOC = @docid

		IF @ddid IS NULL
		BEGIN
			INSERT INTO dbo.DistrDocumentTable(DD_ID_DISTR, DD_ID_DOC, DD_PRINT, DD_ID_GOOD, DD_ID_UNIT)
			VALUES (@distrid, @docid, @print, @goodid, @unitid)
		END
		ELSE
		BEGIN
			UPDATE dbo.DistrDocumentTable
			SET DD_PRINT = @print,
				DD_ID_GOOD = @goodid,
				DD_ID_UNIT = @unitid
			WHERE DD_ID = @ddid
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
GRANT EXECUTE ON [dbo].[DISTR_DOC_PROCESS] TO rl_distr_financing_w;
GO
