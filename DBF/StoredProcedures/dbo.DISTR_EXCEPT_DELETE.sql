USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[DISTR_EXCEPT_DELETE] 
	@id INT
AS
BEGIN
	SET NOCOUNT ON
	
	DELETE 
	FROM dbo.DistrExceptTable 
	WHERE DE_ID = @id

	SET NOCOUNT OFF
END
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_DELETE]  TO rl_reg_node_report_r