USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  ������� ��� ������������ � 
               ��������� ����� �� �����������
*/

CREATE PROCEDURE [dbo].[PRICE_GOOD_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PriceGoodTable 
	WHERE PGD_ID = @id

	SET NOCOUNT OFF
END
