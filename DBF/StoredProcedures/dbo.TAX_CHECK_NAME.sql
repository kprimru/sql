USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 13.01.2009
��������:	  ���������� ID ������ 
                � ��������� ���������. 
*/

CREATE PROCEDURE [dbo].[TAX_CHECK_NAME] 
	@taxname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT TX_ID 
	FROM dbo.TaxTable 
	WHERE TX_NAME = @taxname

	SET NOCOUNT OFF
END