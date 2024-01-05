import s from "./Header.module.scss";
import ethLogo from "../../assets/icons/jbc_24.svg";
import struLogo from "../../assets/images/stru-logo.png";

// import { Icon } from "../SelectIcons/SelectIcons";
import { useEffect } from "react";
import { useAccount, useBalance } from "wagmi";
import { useGetSTRUBalance } from "../../helpers/contractRead";
import { useAppContext } from "../../context/context";
import { ConnectionBtn } from "../ConnectionBtn/ConnectionBtn";
import { formatEther } from "viem";
import { toFixedDigits, formattAddress } from "../../helpers/mathHelpers";
import { DisconnectBtn } from "../DisconnectBtn/DisconnectBtn";

export const Header = () => {
  const { isConnected, address } = useAccount();
  const { data: walletBalance } = useBalance({ address });

  const struBalance = useGetSTRUBalance(String(address));
  const setStruBalance = useAppContext()?.setStruBalance;
  const formattedWalletBalance = toFixedDigits(
    Number(walletBalance?.formatted)
  );
  const formattedAddress = formattAddress(String(address));
  const formattedStruBalance =
    struBalance && typeof struBalance === "bigint"
      ? toFixedDigits(Number(formatEther(struBalance)))
      : "0";

  useEffect(() => {
    if (isConnected && setStruBalance) {
      setStruBalance(formattedStruBalance);
    }
  }, [formattedStruBalance, setStruBalance, isConnected]);

  return (
    <header className={s.header}>
      <div className={s.header_container}>
        <a
          href="#"
          rel="noreferrer"
        >

          <img className={s.eth_logo} src={ethLogo} alt="Ethereum logo" />
        </a>
        {isConnected ? (
          <div className={s.wallet_info}>
            <img className={s.stru_logo} src={struLogo} alt="ATOKEN logo" />
            {formattedStruBalance ? formattedStruBalance : "0.00"} ATOKEN
            <img className={s.eth_logo} src={ethLogo} alt="Ethereum logo" />
            {walletBalance ? formattedWalletBalance : "0.00"}{" "}
            {walletBalance?.symbol}
            <span className={s.wallet_adress}>|</span>
            <span className={s.wallet_adress}>
              {address ? formattedAddress : "unknown"}
            </span>
            <DisconnectBtn />
          </div>
        ) : (
          <div className={s.connect_btn_box}>
            <ConnectionBtn />
          </div>
        )}
      </div>
    </header>
  );
};
