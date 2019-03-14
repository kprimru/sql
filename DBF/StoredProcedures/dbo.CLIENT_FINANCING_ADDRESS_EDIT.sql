USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	



/*
�����:			������� �������
��������:		��������� ������� ������ � ���.���-�� �������
				���� @cfaid �� ���� (����� ���.��������� ����� �������� ������),
				���������� ��� ������ �� @atlid, ����� ���� ������ � ���-�� @fatid 
				������������� ������ @atlid.
����:			17.07.2009
*/

CREATE PROCEDURE [dbo].[CLIENT_FINANCING_ADDRESS_EDIT] 
	@cfaid INT,
	@atlid SMALLINT,
	@clid INT,
	@fatid SMALLINT
AS

BEGIN
	SET NOCOUNT ON

	IF ((@cfaid IS NOT NULL) AND (@cfaid <> 0))
		BEGIN
			UPDATE dbo.ClientFinancingAddressTable
			SET CFA_ID_ATL = @atlid
			WHERE CFA_ID = @cfaid
			
			SELECT @cfaid AS NEW_IDEN
		END
	ELSE
		BEGIN
			INSERT INTO dbo.ClientFinancingAddressTable (
					CFA_ID_CLIENT, CFA_ID_FAT, CFA_ID_ATL
				) VALUES (
					@clid, @fatid, @atlid
				)

			SELECT SCOPE_IDENTITY() AS NEW_IDEN
		END

	SET NOCOUNT OFF
END





