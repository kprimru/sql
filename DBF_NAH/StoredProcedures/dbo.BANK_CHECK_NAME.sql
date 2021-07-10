USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[BANK_CHECK_NAME]
	@bankname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT BA_ID
	FROM dbo.BankTable
	WHERE BA_NAME = @bankname

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[BANK_CHECK_NAME] TO rl_bank_w;
GO