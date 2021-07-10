USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			������� �������
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[TO_PERSONAL_EDIT]
	@tpid INT,
	@rpid TINYINT,
	@posid SMALLINT,
	@surname VARCHAR(100),
	@name VARCHAR(100),
	@otch VARCHAR(100),
	@phone VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.TOPersonalTable
	SET
		TP_ID_RP = @rpid,
		TP_ID_POS = @posid,
		TP_SURNAME = @surname,
		TP_NAME = @name,
		TP_OTCH = @otch,
		TP_PHONE = @phone,
		TP_LAST = GETDATE()
	WHERE TP_ID = @tpid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[TO_PERSONAL_EDIT] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_PERSONAL_EDIT] TO rl_to_personal_w;
GO