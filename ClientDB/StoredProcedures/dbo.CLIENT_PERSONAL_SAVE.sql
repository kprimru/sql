USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_SAVE]
	@CLIENT		INT,
	@TYPE		UNIQUEIDENTIFIER,
	@SURNAME	VARCHAR(250),
	@NAME		VARCHAR(250),
	@PATRON		VARCHAR(250),
	@POS		VARCHAR(150),
	@NOTE		VARCHAR(MAX),
	@EMAIL		VARCHAR(50),
	@PHONE		VARCHAR(150),
	@MAP		VARBINARY(MAX) = NULL,
	@FAX		VARCHAR(150) = NULL
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

		SET @SURNAME = LTRIM(RTRIM(@SURNAME))
		SET @NAME = LTRIM(RTRIM(@NAME))
		SET @PATRON = LTRIM(RTRIM(@PATRON))
		SET @POS = LTRIM(RTRIM(@POS))

		-- ���� ��� �������
		IF @TYPE = (SELECT CPT_ID FROM dbo.ClientPersonalType WHERE CPT_PSEDO = 'BUH')
			AND (SELECT Maintenance.GlobalClientAutoClaim()) = 1 BEGIN

			DECLARE
				@OLD_SURNAME	VarChar(250),
				@OLD_NAME		VarChar(250),
				@OLD_PATRON		VarChar(250);

			SELECT
				@OLD_SURNAME = CP_SURNAME,
				@OLD_NAME = CP_NAME,
				@OLD_PATRON = CP_PATRON
			FROM dbo.ClientPersonal
			WHERE CP_ID_CLIENT =
				(
					SELECT TOP 1 ClientID
					FROM dbo.ClientTable
					WHERE ID_MASTER = @CLIENT
						AND ClientID <> @CLIENT
					ORDER BY ClientLast DESC
				) AND CP_ID_TYPE = @TYPE;



			-- ���� ���������� ���-�� �������
			IF @OLD_SURNAME IS NOT NULL BEGIN
				IF (
					SELECT SUM(CNT)
					FROM
					(
						SELECT [CNT] = CASE WHEN @OLD_SURNAME <> @SURNAME THEN 1 ELSE 0 END
						UNION ALL
						SELECT [CNT] = CASE WHEN @OLD_NAME <> @NAME THEN 1 ELSE 0 END
						UNION ALL
						SELECT [CNT] = CASE WHEN @OLD_PATRON <> @PATRON THEN 1 ELSE 0 END
					) AS B
					) > 1 BEGIN
					INSERT INTO dbo.ClientStudyClaim(ID_CLIENT, DATE, NOTE, REPEAT, UPD_USER)
						SELECT @CLIENT, dbo.Dateof(GETDATE()), '����� �������� ����������', 0, '�������'
						WHERE NOT EXISTS
							(
								SELECT *
								FROM dbo.ClientStudyClaim a
								WHERE ID_CLIENT = @CLIENT
								    AND STATUS IN (1, 4, 5, 9)
									AND UPD_USER = '�������'
							)
				END

			END;
		END;

		INSERT INTO dbo.ClientPersonal(CP_ID_CLIENT, CP_ID_TYPE, CP_SURNAME, CP_NAME, CP_PATRON, CP_POS, CP_NOTE, CP_EMAIL, CP_PHONE, CP_FAX, CP_PHONE_S)
			SELECT @CLIENT, @TYPE, @SURNAME, @NAME, @PATRON, @POS, @NOTE, @EMAIL, @PHONE, @FAX, dbo.PhoneString(@PHONE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_SAVE] TO rl_client_save;
GO
