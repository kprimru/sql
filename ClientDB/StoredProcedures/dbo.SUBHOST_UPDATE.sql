USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SUBHOST_UPDATE]
    @Id             UniqueIdentifier,
    @Name           VarChar(100),
    @Reg            VarChar(20),
    @RegAdd         VarChar(20),
    @Email          VarChar(50),
    @OddEmail       VarChar(256),
    @Client_Id      Int,
    @SeminarDefault Int
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

        SET @RegAdd = NullIf(@RegAdd, '');

		UPDATE dbo.Subhost SET
		    SH_NAME                     = @Name,
		    SH_REG                      = @Reg,
		    SH_REG_ADD                  = @RegAdd,
		    SH_EMAIL                    = @Email,
		    SH_ODD_EMAIL                = @OddEmail,
		    SH_ID_CLIENT                = @Client_Id,
		    SH_SEMINAR_DEFAULT_COUNT    = @SeminarDefault
		WHERE SH_ID = @Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
