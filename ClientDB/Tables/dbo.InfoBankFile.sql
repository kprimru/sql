USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InfoBankFile]
(
        [IBF_ID]      Int             Identity(1,1)   NOT NULL,
        [IBF_ID_IB]   SmallInt                        NOT NULL,
        [IBF_NAME]    NVarChar(512)                   NOT NULL,
        CONSTRAINT [PK_dbo.InfoBankFile] PRIMARY KEY NONCLUSTERED ([IBF_ID]),
        CONSTRAINT [FK_dbo.InfoBankFile(IBF_ID_IB)_dbo.InfoBankTable(InfoBankID)] FOREIGN KEY  ([IBF_ID_IB]) REFERENCES [dbo].[InfoBankTable] ([InfoBankID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.InfoBankFile(IBF_ID_IB,IBF_ID)] ON [dbo].[InfoBankFile] ([IBF_ID_IB] ASC, [IBF_ID] ASC);
GO
