USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ������� ���� �� ����������� �����
*/

ALTER PROCEDURE [dbo].[FIELD_DELETE]
	@fieldid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.FieldTable WHERE FL_ID = @fieldid

	SET NOCOUNT OFF
END


GO
