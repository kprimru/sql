USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ������� �� ����������� ���
               �������������� � ��������� �����
*/

ALTER PROCEDURE [dbo].[FINANCING_DELETE]
	@financingid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.FinancingTable
	WHERE FIN_ID = @financingid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[FINANCING_DELETE] TO rl_financing_d;
GO