USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_DETAIL_INSERT]
	@INS_ID		UNIQUEIDENTIFIER,
	@ID_ID		UNIQUEIDENTIFIER,
	@SYS_ID		UNIQUEIDENTIFIER,
	@DT_ID		UNIQUEIDENTIFIER,
	@NT_ID		UNIQUEIDENTIFIER,
	@TT_ID		UNIQUEIDENTIFIER,
	@COUNT		TINYINT,
	@IND_LOCK	BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)



	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)
	DECLARE @IND_ID UNIQUEIDENTIFIER

	DECLARE @I INT

	SET @I = 0

	WHILE @I < @COUNT
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', NULL, @OLD OUTPUT


		INSERT INTO Install.InstallDetail(
	 			IND_ID_INSTALL, IND_ID_INCOME, IND_ID_SYSTEM, IND_ID_TYPE, IND_ID_NET,
				IND_ID_TECH, IND_LOCK)
		OUTPUT INSERTED.IND_ID INTO @TBL
		VALUES(@INS_ID, @ID_ID, @SYS_ID, @DT_ID, @NT_ID, @TT_ID, @IND_LOCK)

		SELECT @IND_ID = ID
		FROM @TBL

		SET @I = @I + 1

		EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @IND_ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INSTALL_DETAIL', '����� ������', @IND_ID, @OLD, @NEW

	END


END
GO
GRANT EXECUTE ON [Install].[INSTALL_DETAIL_INSERT] TO rl_install_i;
GO
