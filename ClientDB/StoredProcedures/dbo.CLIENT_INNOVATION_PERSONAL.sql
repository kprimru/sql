USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_INNOVATION_PERSONAL]
	@ID			UNIQUEIDENTIFIER,
	@INNOVATION	UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@SURNAME	NVARCHAR(256),
	@NAME		NVARCHAR(256),
	@PATRON		NVARCHAR(256),
	@POSITION	NVARCHAR(256),
	@NOTE		NVARCHAR(MAX)
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

		IF @ID IS NULL
			INSERT INTO dbo.ClientInnovationPersonal(ID_INNOVATION, DATE, SURNAME, NAME, PATRON, POSITION, NOTE)
				VALUES(@INNOVATION, @DATE, @SURNAME, @NAME, @PATRON, @POSITION, @NOTE)
		ELSE
			UPDATE dbo.ClientInnovationPersonal
			SET	DATE		=	@DATE,
				SURNAME		=	@SURNAME,
				NAME		=	@NAME,
				PATRON		=	@PATRON,
				POSITION	=	@POSITION,
				NOTE		=	@NOTE
			WHERE ID = @ID
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
