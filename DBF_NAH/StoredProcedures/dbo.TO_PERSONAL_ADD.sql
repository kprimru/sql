USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:	  �������� ���������� �������
*/

ALTER PROCEDURE [dbo].[TO_PERSONAL_ADD]
	@toid INT,
	@rpid TINYINT,
	@posid SMALLINT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@phone varchar(100),
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.TOPersonalTable(
								TP_ID_TO, TP_ID_RP, TP_ID_POS, TP_SURNAME,
								TP_NAME, TP_OTCH, TP_PHONE, TP_LAST
								)
	VALUES (
			@toid, @rpid, @posid, @surname, @name, @otch, @phone, GETDATE()
			)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TO_PERSONAL_ADD] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_PERSONAL_ADD] TO rl_to_personal_w;
GO