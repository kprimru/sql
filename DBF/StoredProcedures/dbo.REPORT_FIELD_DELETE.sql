USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ������� ���� �� ������� ������ �� ������
*/

CREATE PROCEDURE [dbo].[REPORT_FIELD_DELETE]
	@fieldid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM dbo.ReportFieldTable         
    WHERE RF_ID = @fieldid                     
END


