USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			������� �������
��������:		
����:			16.07.2009
*/

CREATE PROCEDURE [dbo].[ADDRESS_TEMPLATE_DELETE] 
	@atlid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.AddressTemplateTable WHERE ATL_ID = @atlid

	SET NOCOUNT OFF
END

