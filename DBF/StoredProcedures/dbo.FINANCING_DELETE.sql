USE [DBF]
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

CREATE PROCEDURE [dbo].[FINANCING_DELETE] 
	@financingid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.FinancingTable 
	WHERE FIN_ID = @financingid

	SET NOCOUNT OFF
END
