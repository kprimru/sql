USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BankTable]
(
        [BA_ID]         SmallInt       Identity(1,1)   NOT NULL,
        [BA_NAME]       VarChar(250)                   NOT NULL,
        [BA_ID_CITY]    SmallInt                           NULL,
        [BA_PHONE]      VarChar(50)                        NULL,
        [BA_MFO]        VarChar(50)                        NULL,
        [BA_CALC]       VarChar(50)                        NULL,
        [BA_BIK]        VarChar(50)                        NULL,
        [BA_LORO]       VarChar(50)                        NULL,
        [BA_ACTIVE]     Bit                            NOT NULL,
        [BA_OLD_CODE]   Int                                NULL,
        CONSTRAINT [PK_dbo.BankTable] PRIMARY KEY CLUSTERED ([BA_ID]),
        CONSTRAINT [FK_dbo.BankTable(BA_ID_CITY)_dbo.CityTable(CT_ID)] FOREIGN KEY  ([BA_ID_CITY]) REFERENCES [dbo].[CityTable] ([CT_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.BankTable(BA_NAME,BA_ID_CITY)] ON [dbo].[BankTable] ([BA_NAME] ASC, [BA_ID_CITY] ASC);
GO
