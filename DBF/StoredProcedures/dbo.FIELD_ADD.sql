USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  �������� ����� ���� � ���������� �����
*/

CREATE PROCEDURE [dbo].[FIELD_ADD] 
	@fieldname VARCHAR(50),
	@fieldwidth INT,
	@fieldcaption VARCHAR(50),
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.FieldTable(FL_NAME, FL_WIDTH, FL_CAPTION) 
	VALUES (@fieldname, @fieldwidth, @fieldcaption)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END