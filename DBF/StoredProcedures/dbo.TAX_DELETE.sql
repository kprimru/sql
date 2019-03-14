USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 13.01.2009
��������:	  ������� ����� �� �����������
*/

CREATE PROCEDURE [dbo].[TAX_DELETE] 
	@taxid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.TaxTable 
	WHERE TX_ID = @taxid

	SET NOCOUNT OFF
END