USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� ID ���� ��������������
                � ��������� ���������.
*/

ALTER PROCEDURE [dbo].[FINANCING_CHECK_NAME]
	@financingname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT FIN_ID
	FROM dbo.FinancingTable
	WHERE FIN_NAME = @financingname

	SET NOCOUNT OFF
END





GO
GRANT EXECUTE ON [dbo].[FINANCING_CHECK_NAME] TO rl_financing_w;
GO