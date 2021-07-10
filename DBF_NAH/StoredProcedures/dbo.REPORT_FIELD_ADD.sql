USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  �������� ������ � ���� � ������
*/

ALTER PROCEDURE [dbo].[REPORT_FIELD_ADD]
	@fieldname VARCHAR(50),
	@fieldcaption VARCHAR(100),
	@order INT
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO dbo.ReportFieldTable(RF_NAME, RF_CAPTION, RF_ORDER)
                          VALUES(@fieldname, @fieldcaption, @order)
END



GO
