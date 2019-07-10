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

CREATE PROCEDURE [dbo].[REG_NODE_NOT_FOUND_REG]
AS
BEGIN
	SET NOCOUNT ON

	SELECT DIS_STR, CL_PSEDO, CL_FULL_NAME, CL_ID, TO_ID, TO_NUM
	FROM 
		dbo.DistrView a LEFT OUTER JOIN
		dbo.ClientDistrTable b ON CD_ID_DISTR = DIS_ID LEFT OUTER JOIN
		dbo.ClientTable ON CL_ID = CD_ID_CLIENT LEFT OUTER JOIN
		dbo.ToDistrTable ON TD_ID_DISTR = a.DIS_ID LEFT OUTER JOIN
		dbo.ToTable ON TO_ID = TD_ID_TO
	WHERE NOT EXISTS
				(
					SELECT * 
					FROM dbo.RegNodeTable
					WHERE 
						RN_SYS_NAME = a.SYS_REG_NAME AND
						RN_DISTR_NUM = a.DIS_NUM AND
						RN_COMP_NUM = a.DIS_COMP_NUM
				) 
		AND	SYS_REG_NAME <> '-'
		AND DIS_ACTIVE = 1

	SET NOCOUNT OFF
END











