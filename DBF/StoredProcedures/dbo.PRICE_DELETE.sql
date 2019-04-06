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

CREATE PROCEDURE [dbo].[PRICE_DELETE] 
	@priceid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PriceTable 
	WHERE PP_ID = @priceid

	SET NOCOUNT OFF
END