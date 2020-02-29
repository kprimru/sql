USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INSERT_SYS_BY_ID_BLACKLIST]
	@ID_SYS INT,
	@DISTR INT,
	@COMP INT,
	@COMMENT VARCHAR(300),
	@RESULT INT = NULL OUTPUT
WITH EXECUTE AS OWNER
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

		declare @COMPLECT VARCHAR(20)

		SET @COMPLECT = (SELECT COMPLECT FROM dbo.REGNODETABLE r WHERE (r.DistrNumber=@DISTR)and(r.CompNumber=@COMP)and(r.SystemName=(select SystemBaseName from  SystemTable where SystemID=@ID_SYS) ))

		IF EXISTS (SELECT ID FROM  dbo.BLACK_LIST_REG WHERE
				  (DISTR = @DISTR) AND (COMP = @COMP) AND (ID_SYS = @ID_SYS) AND (P_DELETE=0))
		BEGIN
			SET @RESULT = -1
			RETURN
		END 

		INSERT INTO dbo.BLACK_LIST_REG (ID_SYS, DISTR, COMP, DATE,COMMENT,U_LOGIN, COMPLECTNAME)
		VALUES (
			  @ID_SYS , @DISTR, @COMP, getdate(), @COMMENT , ORIGINAL_LOGIN(), @COMPLECT
			   )
		SET @RESULT = @@ERROR
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END