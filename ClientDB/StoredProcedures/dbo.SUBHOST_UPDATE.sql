USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SUBHOST_UPDATE]
    @Id             UniqueIdentifier,
    @Name           VarChar(100),
    @Reg            VarChar(20),
    @RegAdd         VarChar(20),
    @Email          VarChar(50),
    @OddEmail       VarChar(256),
    @Client_Id      Int,
    @SeminarDefault Int,
	@Active			Bit,
	@Emails			Xml
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
		    SH_SEMINAR_DEFAULT_COUNT    = @SeminarDefault,
			SH_ACTIVE					= @Active
		WHERE SH_ID = @Id;

		DELETE FROM [dbo].[SubhostEmail] WHERE [Subhost_Id] = @Id;

		INSERT INTO [dbo].[SubhostEmail]([Subhost_Id], [Type_Id], [Email])
		SELECT [Subhost_Id], [Type_Id], [Email]
		FROM
		(
			SELECT
				[Subhost_Id]	= @Id,
				[Type_Id]		= c.value('@Id[1]',		'TinyInt'),
				[Email]			= c.value('@Email[1]',	'VarChar(512)')
			FROM @Emails.nodes('/root/item') a(c)
		) AS N
		WHERE N.[Email] != '';

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_UPDATE] TO rl_subhost_u;
GO
