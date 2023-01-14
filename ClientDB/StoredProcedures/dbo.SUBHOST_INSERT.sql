USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_INSERT]
    @Name           VarChar(100),
    @Reg            VarChar(20),
    @RegAdd         VarChar(20),
    @Email          VarChar(50),
    @OddEmail       VarChar(256),
    @Client_Id      Int,
    @SeminarDefault Int,
	@Active			Bit,
    @Id             UniqueIdentifier = NULL OUTPUT
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

        SET @Id = NewId();

        SET @RegAdd = NullIf(@RegAdd, '');

        INSERT INTO dbo.Subhost(SH_ID, SH_NAME, SH_REG, SH_REG_ADD, SH_EMAIL, SH_ODD_EMAIL, SH_ID_CLIENT, SH_SEMINAR_DEFAULT_COUNT, SH_ACTIVE)
        VALUES(@Id, @Name, @Reg, @RegAdd, @Email, @OddEmail, @Client_Id, @SeminarDefault, @Active);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_INSERT] TO rl_subhost_i;
GO
